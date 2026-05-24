#!/bin/bash
#SBATCH -A research
#SBATCH --qos=medium
#SBATCH -p u22
#SBATCH -n 10
#SBATCH --mem=40G
#SBATCH --time=72:00:00
#SBATCH --output=bg_generation_%j.log
#SBATCH --mail-type=END
#SBATCH --mail-user=manas.agrawal@research.iiit.ac.in

# -----------------------------------------------------------------------
# 1. Setup environment
# -----------------------------------------------------------------------
source $(conda info --base)/etc/profile.d/conda.sh
conda activate madgraph

export PYTHIA8DATA=''

mkdir -p /scratch/mg5_scratch/
mkdir -p /scratch/madgraph_runs/
export TMPDIR=/scratch/mg5_scratch

MG5=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/bin/mg5_aMC
OUTBASE=/scratch/madgraph_runs/
RUN_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/cards/run_card.dat
PYTHIA_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/cards/pythia8_card.dat
DELPHES_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/cards/delphes_card.tcl

send_update() {
    echo "Job ID $SLURM_JOB_ID: $1" | mail -s "BG Generation Update" manas.agrawal@research.iiit.ac.in
}

send_update "Starting background generation"

# -----------------------------------------------------------------------
# 2. W+jets
# -----------------------------------------------------------------------
echo "Starting W+jets..."
cat > /tmp/mg5_Wjets.txt << EOF
import model sm
generate p p > w+ j j, (w+ > l+ vl)
add process p p > w- j j, (w- > l- vl~)
output ${OUTBASE}/BG_Wjets
launch ${OUTBASE}/BG_Wjets
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_Wjets.txt
send_update "W+jets done"

# -----------------------------------------------------------------------
# 3. Z+jets
# -----------------------------------------------------------------------
echo "Starting Z+jets..."
cat > /tmp/mg5_Zjets.txt << EOF
import model sm
generate p p > z j j, (z > l+ l-)
output ${OUTBASE}/BG_Zjets
launch ${OUTBASE}/BG_Zjets
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_Zjets.txt
send_update "Z+jets done"

# -----------------------------------------------------------------------
# 4. tt+jets
# -----------------------------------------------------------------------
echo "Starting tt+jets..."
cat > /tmp/mg5_ttjets.txt << EOF
import model sm
generate p p > t t~ j, (t > b w+, w+ > l+ vl), (t~ > b~ w-, w- > j j)
add process p p > t t~ j, (t > b w+, w+ > j j), (t~ > b~ w-, w- > l- vl~)
output ${OUTBASE}/BG_ttjets
launch ${OUTBASE}/BG_ttjets
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_ttjets.txt
send_update "tt+jets done"

# -----------------------------------------------------------------------
# 5. tW
# -----------------------------------------------------------------------
echo "Starting tW..."
cat > /tmp/mg5_tW.txt << EOF
import model sm
generate g b > t w-, (t > b l+ vl), (w- > j j)
add process g b~ > t~ w+, (t~ > b~ l- vl~), (w+ > j j)
output ${OUTBASE}/BG_tW
launch ${OUTBASE}/BG_tW
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_tW.txt
send_update "tW done"

# -----------------------------------------------------------------------
# 6. tb
# -----------------------------------------------------------------------
echo "Starting tb..."
cat > /tmp/mg5_tb.txt << EOF
import model sm
generate p p > t b~, (t > b w+, w+ > l+ vl)
add process p p > t~ b, (t~ > b~ w-, w- > l- vl~)
output ${OUTBASE}/BG_tb
launch ${OUTBASE}/BG_tb
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_tb.txt
send_update "tb done"

# -----------------------------------------------------------------------
# 7. t+jets
# -----------------------------------------------------------------------
echo "Starting t+jets..."
cat > /tmp/mg5_tjets.txt << EOF
import model sm
generate u b > t d, (t > b w+, w+ > l+ vl)
add process c b > t s, (t > b w+, w+ > l+ vl)
add process d b~ > t~ u, (t~ > b~ w-, w- > l- vl~)
add process s b~ > t~ c, (t~ > b~ w-, w- > l- vl~)
output ${OUTBASE}/BG_tjets
launch ${OUTBASE}/BG_tjets
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_tjets.txt
send_update "t+jets done"

# -----------------------------------------------------------------------
# 8. WW+jets
# -----------------------------------------------------------------------
echo "Starting WW+jets..."
cat > /tmp/mg5_WWjets.txt << EOF
import model sm
generate p p > w+ w- j, (w+ > l+ vl), (w- > j j)
add process p p > w+ w- j, (w+ > j j), (w- > l- vl~)
output ${OUTBASE}/BG_WWjets
launch ${OUTBASE}/BG_WWjets
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_WWjets.txt
send_update "WW+jets done"

# -----------------------------------------------------------------------
# 9. WZ+jets
# -----------------------------------------------------------------------
echo "Starting WZ+jets..."
cat > /tmp/mg5_WZjets.txt << EOF
import model sm
generate p p > w+ z j, (w+ > l+ vl), (z > j j)
add process p p > w- z j, (w- > l- vl~), (z > j j)
output ${OUTBASE}/BG_WZjets
launch ${OUTBASE}/BG_WZjets
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_WZjets.txt
send_update "WZ+jets done"

# -----------------------------------------------------------------------
# 10. ttZ
# -----------------------------------------------------------------------
echo "Starting ttZ..."
cat > /tmp/mg5_ttZ.txt << EOF
import model sm
generate p p > t t~ z, (t > b w+, w+ > l+ vl), (t~ > b~ w-, w- > j j), (z > j j)
add process p p > t t~ z, (t > b w+, w+ > j j), (t~ > b~ w-, w- > l- vl~), (z > j j)
output ${OUTBASE}/BG_ttZ
launch ${OUTBASE}/BG_ttZ
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_ttZ.txt
send_update "ttZ done"

# -----------------------------------------------------------------------
# 11. ttW
# -----------------------------------------------------------------------
echo "Starting ttW..."
cat > /tmp/mg5_ttW.txt << EOF
import model sm
generate p p > t t~ w+, (t > b l+ vl), (t~ > b~ j j), (w+ > j j)
add process p p > t t~ w-, (t > b j j), (t~ > b~ l- vl~), (w- > j j)
output ${OUTBASE}/BG_ttW
launch ${OUTBASE}/BG_ttW
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_ttW.txt
send_update "ttW done"

# -----------------------------------------------------------------------
# 12. ttH
# -----------------------------------------------------------------------
echo "Starting ttH..."
cat > /tmp/mg5_ttH.txt << EOF
import model sm
generate p p > t t~ h, (t > b w+, w+ > l+ vl), (t~ > b~ w-, w- > j j)
add process p p > t t~ h, (t > b w+, w+ > j j), (t~ > b~ w-, w- > l- vl~)
output ${OUTBASE}/BG_ttH
launch ${OUTBASE}/BG_ttH
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_ttH.txt
send_update "ttH done"

# -----------------------------------------------------------------------
send_update "All 11 background processes complete"
echo "All backgrounds done."
