/*
 * vlq_analysis.cpp
 * Applies cuts C1-C6 for VLQ singlet B quark analysis (PRD 107, 115001)
 * Signal topology: pp -> B B~ -> (b Phi)(t W), Phi->gg or bb, W->lv or t->blv
 * Final state: exactly 1 lepton + >=1 b-jet + jets + AK12 fat jet (R=1.2)
 *
 * Uses Delphes-bundled FastJet + Nsubjettiness (no separate fastjet contrib install needed).
 *
 * Build:
 *   export DELPHES_DIR=/path/to/Delphes-3.x.x
 *   g++ -std=c++17 -O2 -o vlq_analysis vlq_analysis.cpp \
 *       $(root-config --cflags --libs) \
 *       -I${DELPHES_DIR} -I${DELPHES_DIR}/external \
 *       -L${DELPHES_DIR} -lDelphes
 *
 * Run:
 *   ./vlq_analysis <num_files> <input1.root> [input2.root ...] <output.txt>
 *
 * Example:
 *   ./vlq_analysis 1 tag_1_delphes_events.root output_MB1200.txt
 *
 * Paper Table II reference (MB=1200, MPhi=400, L=3 ab^-1):
 *   C1=2619  C2=1681  C3=1677  C4=1628  C5=1176  C6=1029
 *   Sequential efficiencies: C2/C1=64.2%, C3/C2=99.8%, C4/C3=97.1%,
 *                             C5/C4=72.2%, C6/C5=87.5%
 *
 * NOTE: C2 efficiency will differ from paper if only the hadronic-top
 *       sub-channel (t->bjj, W->lv) was generated. The paper includes
 *       both sub-channels (leptonic top t->blv + hadronic W also contributes).
 *       C4 efficiency is lower with Phi->gg than Phi->bb (fewer b-jets available).
 */

// ─── Standard headers ────────────────────────────────────────────────────────
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>

// ─── ROOT ────────────────────────────────────────────────────────────────────
#include "TROOT.h"
#include "TSystem.h"
#include "TChain.h"
#include "TClonesArray.h"
#include "TLorentzVector.h"
#include "TH1F.h"

// ─── Delphes ─────────────────────────────────────────────────────────────────
// Use paths from Dilepton_Scalar.C — requires -I${DELPHES_DIR}/external
#include "external/ExRootAnalysis/ExRootTreeReader.h"
#include "classes/DelphesClasses.h"

// ─── FastJet (Delphes-bundled, via -I${DELPHES_DIR}/external) ────────────────
#include "fastjet/PseudoJet.hh"
#include "fastjet/ClusterSequence.hh"
#include "fastjet/contribs/Nsubjettiness/Njettiness.hh"
#include "fastjet/contribs/Nsubjettiness/Nsubjettiness.hh"
#include "fastjet/contribs/Nsubjettiness/NjettinessPlugin.hh"

using namespace std;
using namespace fastjet;
using namespace fastjet::contrib;

// ─── Utility ─────────────────────────────────────────────────────────────────

bool sortByPt(const TLorentzVector &a, const TLorentzVector &b) {
    return a.Pt() > b.Pt();
}

double deltaR(double eta1, double phi1, double eta2, double phi2) {
    double dphi = fabs(phi1 - phi2);
    if (dphi > M_PI) dphi = 2.0 * M_PI - dphi;
    return sqrt((eta1 - eta2) * (eta1 - eta2) + dphi * dphi);
}

// ─── Cut parameters (paper Section III B) ────────────────────────────────────

// C1: exactly 1 lepton (e or mu)
const double MIN_PT_LEP      = 100.0; // GeV
const double MAX_ETA_LEP     = 2.5;

// C2: HT > 900 GeV (scalar sum of pT of all hadronic objects)
const double MIN_HT          = 900.0; // GeV

// C3: >= 3 AK4 jets with pT > 60 GeV; leading jet pT > 120 GeV
const int    MIN_AK4_JETS    = 3;
const double MIN_PT_AK4      = 60.0;  // GeV
const double MIN_PT_LEADING  = 120.0; // GeV
const double MAX_ETA_AK4     = 5.0;

// C4: >= 1 b-tagged AK4 jet with pT > 60 GeV
const double MIN_PT_BJET     = 60.0;  // GeV

// C5: >= 1 AK12 fat jet (R=1.2, re-clustered from towers)
//     pT > 500 GeV AND invariant mass MJ > 250 GeV
const double FATJET_R        = 1.2;
const double MIN_PT_FATJET   = 500.0; // GeV
const double MIN_MASS_FATJET = 250.0; // GeV

// C6: at least ONE b-jet well-separated from the leading fat jet
//     ΔR(b, J) > 1.2  (paper: "at least one identified b jet", not just the leading one)
const double MIN_DR_B_FATJET = 1.2;

// ─────────────────────────────────────────────────────────────────────────────

int main(int argc, char *argv[]) {

    if (argc < 3) {
        cerr << "Usage: " << argv[0]
             << " <num_files> <input1.root> [input2.root ...] <output.txt>" << endl;
        return 1;
    }

    int num_files = atoi(argv[1]);
    if (argc < 2 + num_files + 1) {
        cerr << "Error: expected " << num_files
             << " input file(s) + 1 output file." << endl;
        return 1;
    }

    string outfile_name = argv[2 + num_files];

    // ─── Load Delphes and open input chain ───────────────────────────────────
    gSystem->Load("libDelphes");
    TChain chain("Delphes");
    for (int i = 0; i < num_files; i++) {
        chain.Add(argv[2 + i]);
        cout << "Added: " << argv[2 + i] << endl;
    }

    ExRootTreeReader *reader = new ExRootTreeReader(&chain);
    Long64_t nEvents = reader->GetEntries();
    cout << "Total events: " << nEvents << endl;

    // ─── Branches ────────────────────────────────────────────────────────────
    TClonesArray *branchJet      = reader->UseBranch("Jet");
    TClonesArray *branchElectron = reader->UseBranch("Electron");
    TClonesArray *branchMuon     = reader->UseBranch("Muon");
    TClonesArray *branchMissingET= reader->UseBranch("MissingET");
    TClonesArray *branchTower    = reader->UseBranch("Tower");

    // ─── Fat-jet clustering (AK12, R=1.2) from towers ────────────────────────
    // Matches paper Section III: "clustered using the anti-kT algorithm with R=1.2"
    JetDefinition fatjet_def(antikt_algorithm, FATJET_R, E_scheme, Best);

    // ─── N-subjettiness ratios (Delphes-bundled FastJet contrib) ─────────────
    // Used both as DNN features (output) — not applied as cuts (paper does not cut on tau)
    // beta=1 and beta=2 as listed in paper Section III D
    NsubjettinessRatio nSub21_b1(2, 1, OnePass_KT_Axes(), UnnormalizedMeasure(1.0));
    NsubjettinessRatio nSub21_b2(2, 1, OnePass_KT_Axes(), UnnormalizedMeasure(2.0));
    NsubjettinessRatio nSub32_b1(3, 2, OnePass_KT_Axes(), UnnormalizedMeasure(1.0));
    NsubjettinessRatio nSub32_b2(3, 2, OnePass_KT_Axes(), UnnormalizedMeasure(2.0));

    // ─── Cut counters (cumulative — each count is events FAILING that cut) ────
    long long n_total = nEvents;
    long long pass_c1 = 0, pass_c2 = 0, pass_c3 = 0;
    long long pass_c4 = 0, pass_c5 = 0, pass_c6 = 0;

    // ─── Output: tab-separated DNN input features for events passing C1-C6 ───
    ofstream outfile(outfile_name);
    if (!outfile.is_open()) {
        cerr << "Error: cannot open output file " << outfile_name << endl;
        return 1;
    }
    outfile << "# HT\tMET\tpT_lep\teta_lep\t"
            << "pT_j1\tpT_j2\tpT_j3\t"
            << "pT_bj\t"
            << "pT_fatj\tfatj_mass\teta_fatj\t"
            << "tau21_b1\ttau21_b2\ttau32_b1\ttau32_b2\t"
            << "dR_b_fatj\tdR_lep_fatj\t"
            << "m_b_fatj\n";

    // ─── Event loop ──────────────────────────────────────────────────────────
    for (Long64_t ev = 0; ev < nEvents; ev++) {
        reader->ReadEntry(ev);

        // ── Collect leptons (electrons + muons) ──────────────────────────────
        vector<TLorentzVector> leptons;

        for (int i = 0; i < branchElectron->GetEntriesFast(); i++) {
            Electron *el = (Electron*) branchElectron->At(i);
            // Barrel-endcap gap veto (1.37 < |eta| < 1.52) omitted here;
            // paper applies isolation via modified Delphes card (DeltaRMax=0.2)
            if (el->PT > MIN_PT_LEP && fabs(el->Eta) < MAX_ETA_LEP) {
                leptons.push_back(el->P4());
            }
        }

        for (int i = 0; i < branchMuon->GetEntriesFast(); i++) {
            Muon *mu = (Muon*) branchMuon->At(i);
            if (mu->PT > MIN_PT_LEP && fabs(mu->Eta) < MAX_ETA_LEP) {
                leptons.push_back(mu->P4());
            }
        }

        sort(leptons.begin(), leptons.end(), sortByPt);

        // ── C1: Exactly 1 lepton ─────────────────────────────────────────────
        if ((int)leptons.size() != 1) continue;
        pass_c1++;

        // ── Collect AK4 jets and b-jets from Delphes ─────────────────────────
        // HT = scalar sum of pT of all hadronic objects (paper Section III B, C2)
        // Use all AK4 jets passing pT > 60 GeV and |eta| < 5
        vector<TLorentzVector> ak4jets;
        vector<TLorentzVector> bjets;
        double HT = 0.0;

        for (int i = 0; i < branchJet->GetEntriesFast(); i++) {
            Jet *jt = (Jet*) branchJet->At(i);
            if (jt->PT > MIN_PT_AK4 && fabs(jt->Eta) < MAX_ETA_AK4) {
                TLorentzVector v = jt->P4();
                ak4jets.push_back(v);
                HT += jt->PT;
                if (jt->BTag && jt->PT > MIN_PT_BJET) {
                    bjets.push_back(v);
                }
            }
        }

        sort(ak4jets.begin(), ak4jets.end(), sortByPt);
        sort(bjets.begin(), bjets.end(), sortByPt);

        // ── MET ──────────────────────────────────────────────────────────────
        TLorentzVector met_vec;
        if (branchMissingET->GetEntriesFast() > 0) {
            MissingET *met_obj = (MissingET*) branchMissingET->At(0);
            met_vec = met_obj->P4();
        }

        // ── C2: HT > 900 GeV ─────────────────────────────────────────────────
        if (HT < MIN_HT) continue;
        pass_c2++;

        // ── C3: >= 3 AK4 jets pT > 60; leading jet pT > 120 ─────────────────
        if ((int)ak4jets.size() < MIN_AK4_JETS) continue;
        if (ak4jets[0].Pt() < MIN_PT_LEADING) continue;
        pass_c3++;

        // ── C4: >= 1 b-tagged jet pT > 60 ────────────────────────────────────
        if (bjets.empty()) continue;
        pass_c4++;

        // ── Build AK12 fat jets from calorimeter towers ───────────────────────
        vector<PseudoJet> tower_particles;
        tower_particles.reserve(branchTower->GetEntriesFast());
        for (int i = 0; i < branchTower->GetEntriesFast(); i++) {
            Tower *tw = (Tower*) branchTower->At(i);
            TLorentzVector lv = tw->P4();
            tower_particles.emplace_back(lv.Px(), lv.Py(), lv.Pz(), lv.E());
        }
        ClusterSequence cs(tower_particles, fatjet_def);
        // Pre-select fat jets with pT > 20 GeV before applying C5 thresholds
        vector<PseudoJet> all_fatjets = sorted_by_pt(cs.inclusive_jets(20.0));

        // ── C5: >= 1 fat jet with pT > 500 GeV AND mass > 250 GeV ────────────
        // Paper: "parameters have been optimized to tag a Phi fatjet"
        vector<PseudoJet> good_fatjets;
        for (auto &fj : all_fatjets) {
            if (fj.pt() > MIN_PT_FATJET && fj.m() > MIN_MASS_FATJET) {
                good_fatjets.push_back(fj);
            }
        }
        if (good_fatjets.empty()) continue;
        pass_c5++;

        // Leading good fat jet
        const PseudoJet &leading_fj = good_fatjets[0];
        TLorentzVector fj_vec;
        fj_vec.SetPxPyPzE(leading_fj.px(), leading_fj.py(),
                           leading_fj.pz(), leading_fj.E());

        // ── C6: AT LEAST ONE b-jet with ΔR(b, J) > 1.2 ──────────────────────
        // BUG FIX: paper says "at least one of the identified b jets"
        // NOT only the leading b-jet. Iterate all b-jets.
        bool c6_pass = false;
        int  c6_bjet_idx = -1; // index of the b-jet used for output features
        for (int i = 0; i < (int)bjets.size(); i++) {
            double dr = deltaR(bjets[i].Eta(), bjets[i].Phi(),
                               leading_fj.eta(), leading_fj.phi());
            if (dr > MIN_DR_B_FATJET) {
                c6_pass = true;
                c6_bjet_idx = i;
                break; // use first (highest-pT) b-jet that satisfies the cut
            }
        }
        if (!c6_pass) continue;
        pass_c6++;

        // ── Event passed all cuts: compute output features ────────────────────

        // N-subjettiness of the leading fat jet
        double tau21_b1 = nSub21_b1(leading_fj);
        double tau21_b2 = nSub21_b2(leading_fj);
        double tau32_b1 = nSub32_b1(leading_fj);
        double tau32_b2 = nSub32_b2(leading_fj);

        const TLorentzVector &selected_bjet = bjets[c6_bjet_idx];

        double dr_b_fj   = deltaR(selected_bjet.Eta(), selected_bjet.Phi(),
                                   leading_fj.eta(), leading_fj.phi());
        double dr_lep_fj = deltaR(leptons[0].Eta(), leptons[0].Phi(),
                                   leading_fj.eta(), leading_fj.phi());

        // m(b-jet, fat-jet) — primary B' mass proxy (paper Fig. 6d)
        TLorentzVector bfj_system = selected_bjet + fj_vec;
        double m_b_fatj = bfj_system.M();

        double pT_j1 = ak4jets.size() > 0 ? ak4jets[0].Pt() : 0.0;
        double pT_j2 = ak4jets.size() > 1 ? ak4jets[1].Pt() : 0.0;
        double pT_j3 = ak4jets.size() > 2 ? ak4jets[2].Pt() : 0.0;

        outfile << HT                   << "\t"
                << met_vec.Pt()         << "\t"
                << leptons[0].Pt()      << "\t"
                << leptons[0].Eta()     << "\t"
                << pT_j1                << "\t"
                << pT_j2                << "\t"
                << pT_j3                << "\t"
                << selected_bjet.Pt()   << "\t"
                << fj_vec.Pt()          << "\t"
                << fj_vec.M()           << "\t"
                << leading_fj.eta()     << "\t"
                << tau21_b1             << "\t"
                << tau21_b2             << "\t"
                << tau32_b1             << "\t"
                << tau32_b2             << "\t"
                << dr_b_fj              << "\t"
                << dr_lep_fj            << "\t"
                << m_b_fatj             << "\n";
    }

    outfile.close();

    // ─── Summary ─────────────────────────────────────────────────────────────
    auto eff = [&](long long pass, long long total) {
        return total > 0 ? 100.0 * pass / total : 0.0;
    };
    auto seq_eff = [&](long long pass, long long prev) {
        return prev > 0 ? 100.0 * pass / prev : 0.0;
    };

    cout << "\n========================================" << endl;
    cout << "Total events:              " << n_total  << endl;
    cout << "----------------------------------------" << endl;
    cout << "Pass C1 (exactly 1 lep):  " << pass_c1
         << "  (" << eff(pass_c1, n_total) << "%)" << endl;
    cout << "Pass C2 (HT>900):          " << pass_c2
         << "  (seq: " << seq_eff(pass_c2, pass_c1) << "%)" << endl;
    cout << "Pass C3 (>=3 jets):        " << pass_c3
         << "  (seq: " << seq_eff(pass_c3, pass_c2) << "%)" << endl;
    cout << "Pass C4 (>=1 b-jet):       " << pass_c4
         << "  (seq: " << seq_eff(pass_c4, pass_c3) << "%)" << endl;
    cout << "Pass C5 (fat jet pT+mass): " << pass_c5
         << "  (seq: " << seq_eff(pass_c5, pass_c4) << "%)" << endl;
    cout << "Pass C6 (dR(any-b,J)>1.2):" << pass_c6
         << "  (seq: " << seq_eff(pass_c6, pass_c5) << "%)" << endl;
    cout << "----------------------------------------" << endl;
    cout << "Overall efficiency:        " << eff(pass_c6, n_total) << "%" << endl;
    cout << "C1->C6 efficiency:         " << seq_eff(pass_c6, pass_c1) << "%" << endl;
    cout << "========================================" << endl;
    cout << "\nPaper Table II reference (MB=1200, MPhi=400, L=3ab^-1):" << endl;
    cout << "  C2/C1=64.2%  C3/C2=99.8%  C4/C3=97.1%  C5/C4=72.2%  C6/C5=87.5%" << endl;
    cout << "  NOTE: paper C2 includes leptonic-top sub-channel; C4 uses Phi->bb." << endl;
    cout << "\nOutput written to: " << outfile_name << endl;

    delete reader;
    return 0;
}
