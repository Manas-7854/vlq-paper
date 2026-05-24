
Paper Link: [https://journals.aps.org/prd/pdf/10.1103/PhysRevD.107.115001]


## Steps to reproduce the paper

### Step 1 : Clone the Repository and Generate the param cards
- clone the Repository for with the vectorlikequarks model : [github.com/rsrchtsm/vectorlikequarks]
- move into the `SingBPlusPhi/Vlq_sing_b_plus_phi_ufo` directory and the script for `write_param_card.py` (you must run this using python 2.7)
- run the `compute_br.py` with the following MBP and Meta Value (change these in the for loop at the bottom)
    1. MBP 1200 and Meta 400
    2. MBP 1500 and Meta 400
    3. MBP 1800 and Meta 700
- save the output for all the three and look for the values that give you closest to BR(B'→bΦ) ≈ 60%
- note down the value and create three param cards (one for each MBP value) and change the following parameters from the output of the ` compute_br ` - MBP, Meta, LamdaA, LambdaB, MUB1, MUB2, WBP Decay (6000007) and Weta Decay (6000025)
- you now must have the parameter cards for all the three MBP values (you can also just choose to copy the param cards in this repo)

### Step 2 : Get the Run, Delphes and the Pythia8 cards
- For all these three cards take the default cards that madgraph provides and change the following values:
- `run_card.dat` : 
    ```
    7000.0   = ebeam1     # beam 1 energy → 14 TeV total (HL-LHC)
    7000.0   = ebeam2     # beam 2 energy
    50000    = nevents    # number of events to generate
    nn23lo1  = pdlabel    # PDF set — switched from lhapdf to built-in to avoid install issues
                      # (original plan was lhapdf with lhaid=263000 for NNPDF31)
    10.0     = ptl        # gen-level min pT on leptons — loose, tighter cuts applied later
    20.0     = ptj        # gen-level min pT on jets
    5.0      = etaj       # max eta on jets (note: -1 in original plan, used 5 instead)
    2.5      = etal       # max eta on leptons
    ```
- `Delphes_tcl.dat` :
    ```
        module Isolation ElectronIsolation {
           set DeltaRMax 0.2    # changed from default 0.5 → 0.2 (as per CMS Ref [51] in paper)
        }

        module BTagging BTagging {
            set BitNumber 0
            add EfficiencyFormula {5}  { 0.68 }   # b-jet tagging efficiency (was ~0.77 in default)
            add EfficiencyFormula {4}  { 0.12 }   # charm mistag rate
            add EfficiencyFormula {0}  { 0.01 }   # light jet mistag rate
        }

        module FastJetFinder FatJetFinder {
            set JetAlgorithm  antikt
            set ParameterR    1.2      # changed from 0.8 → 1.2 (paper uses R=1.2 to tag boosted Φ)
            set JetPTMin      20.0     # changed from 200 → 20 GeV (looser, analysis cuts applied later)
            set RPrun         1.2      # changed from 0.8 → 1.2 (pruning radius, must match jet R)
            set R0SoftDrop    1.2      # changed from 0.8 → 1.2 (soft drop radius, must match jet R)
            set OutputArray   fatjets
        }
        module FastJetFinder JetFinder {
            set JetAlgorithm  antikt
            set ParameterR    0.4
            set JetPTMin      20.0
        }
    ```
    - `pythia8 card` :
    ```
        TimeShower:alphaSorder  = 2    # NLO running of αs in final-state radiation
        SpaceShower:alphaSorder = 2    # NLO running of αs in initial-state radiation
        SoftQCD:all             = off  # turn off underlying event/soft QCD (not needed for signal)
        PartonLevel:ISR         = on   # initial state radiation ON
        PartonLevel:FSR         = on   # final state radiation ON
        HadronLevel:all         = on   # full hadronization ON (needed for realistic detector input)
    ```
    - these cards can be modified and saved so that it is easier to use then when needed

### Step 3 : Generate the Signal event
- copy the`Vlq_sing_b_plus_phi_ufo` inside the models folder inside your mg5 directory
- start madgraph and import the VLQ model and use the following generate command :
    ```
        generate p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ j j), (w+ > l+ vl))
        add process p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ l- vl~), (w+ > j j))
        add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b j j), (w- > l- vl~))
        add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b l+ vl), (w- > j j))
        output BB_signal_MB1200_MPhi400_v2
        launch BB_signal_MB1200_MPhi400_v2
    ```
- create an appropriate output directory (the process might take upto 16GBs of temporary storage and after completion might take around 3-4 GB of storage) and launch the process- select pythia and delphes and for the cards use the cards generated above ( this needs to be done three times one for each parameter card - the other cards remain the same)

### Step 4 : Generate the ROOT files for the Background events
- there are 11 background events in total, use the generate commands in `bg_generate.md` to generate the background events (Note that for these the VLQ model is not needed to be imported - just the default model)
- for the cards we will use the default param_card, for run, pythia and delphes cards use the ones generated before

---
#### For steps 1 to 4, mostly it can be automated (apart from the cloning the repo and copying the model part) using the two scripts inside the repository `signal.sh` and `bg.sh` - just update the paths.
- also note that you only need to keep the root files inside the events folder for each event and all the other files can be deleted - although keeping the logs file can be helpful
---

### Step 5: Apply cuts to the signal Events:
- In total we need to appy 6 cuts to the generated root files
- Export the paths to Delphes, Fastjet and LD_Library using the following commands :
    ```
    export DELPHES_DIR=/path/to/Delphes-3.x.x
    export FASTJET_DIR=$(fastjet-config --prefix)
    export LD_LIBRARY_PATH=$DELPHES_DIR:$FASTJET_DIR/lib:$LD_LIBRARY_PATH
    ```
    - if you have the NSubjetiness bundles inside of Delphes you can avoid the FasJet Export
- Compile the vlq_analysis.cpp using the following command 
    `g++ -std=c++17 -O2 -o vlq_analysis vlq_analysis.cpp \ $(root-config --cflags --libs) \ -I${DELPHES_DIR} -I${DELPHES_DIR}/external \ -L${DELPHES_DIR} -lDelphes`
- To run the script use the following command `./vlq_analysis 1 path_to_root_file output.txt` - here 1 is specifing the number of files



- For a proper installation of Madgraph Please follow the steps in `mg_setup.md`
