#!/bin/bash
#SBATCH -A research
#SBATCH --qos=medium
#SBATCH -p u22
#SBATCH -n 10 
#SBATCH --nodelist=gnode007
#SBATCH --mem=40g
#SBATCH --time=72:00:00
#SBATCH --output=signal_generation_%j.log
#SBATCH --mail-type=END
#SBATCH --mail-user=manas.agrawal@research.iiit.ac.in

source $(conda info --base)/etc/profile.d/conda.sh
conda activate madgraph

export PYTHIA8DATA=''

mkdir -p /scratch/mg5_scratch/
mkdir -p /scratch/madgraph_runs/
export TMPDIR=/scratch/mg5_scratch

MG5=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/bin/mg5_aMC
OUTBASE=/scratch/madgraph_runs

RUN_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/cards/run_card.dat
PYTHIA_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/cards/pythia8_card.dat
DELPHES_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/cards/delphes_card.tcl
PARAM_CARD_1200=/home2/manas.agrawal/VLQ_paper/vlq_paper/param_card_mbp_1200.dat
PARAM_CARD_1500=/home2/manas.agrawal/VLQ_paper/vlq_paper/param_card_mbp_1500.dat
PARAM_CARD_1800=/home2/manas.agrawal/VLQ_paper/vlq_paper/param_card_mbp_1800.dat

### Signal MBP 1200 ###
cat > /tmp/mg5_vlq_signal_mbp1200.txt << EOF
import model VLQ_SingB_plus_Phi_UFO/
generate p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ j j), (w+ > l+ vl))
add process p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ l- vl~), (w+ > j j))
add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b j j), (w- > l- vl~))
add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b l+ vl), (w- > j j))
output ${OUTBASE}/VLQ_mbp1200
launch ${OUTBASE}/VLQ_mbp1200
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PARAM_CARD_1200}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_vlq_signal_mbp1200.txt

### Signal MBP 1500 ###
cat > /tmp/mg5_vlq_signal_mbp1500.txt << EOF
import model VLQ_SingB_plus_Phi_UFO/
generate p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ j j), (w+ > l+ vl))
add process p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ l- vl~), (w+ > j j))
add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b j j), (w- > l- vl~))
add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b l+ vl), (w- > j j))
output ${OUTBASE}/VLQ_mbp1500
launch ${OUTBASE}/VLQ_mbp1500
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PARAM_CARD_1500}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_vlq_signal_mbp1500.txt

### Signal MBP 1800 ###
cat > /tmp/mg5_vlq_signal_mbp1800.txt << EOF
import model VLQ_SingB_plus_Phi_UFO/
generate p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ j j), (w+ > l+ vl))
add process p p > bp bp~, (bp > b eta, eta > g g), (bp~ > t~ w+, (t~ > b~ l- vl~), (w+ > j j))
add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b j j), (w- > l- vl~))
add process p p > bp bp~, (bp~ > b~ eta, eta > g g), (bp > t w-, (t > b l+ vl), (w- > j j))
output ${OUTBASE}/VLQ_mbp1800
launch ${OUTBASE}/VLQ_mbp1800
  shower=Pythia8
  detector=Delphes
  ${RUN_CARD}
  ${PARAM_CARD_1800}
  ${PYTHIA_CARD}
  ${DELPHES_CARD}
EOF
$MG5 /tmp/mg5_vlq_signal_mbp1800.txt

echo "All signal processes generated"
  
