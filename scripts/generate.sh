#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate madgraph
MG5=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/bin/mg5_aMC
OUTBASE=/home2/manas.agrawal/VLQ_paper/vlq_paper/dataset/

RUN_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/
PYTHIA_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/
DELPHES_CARD=/home2/manas.agrawal/apps/MG5_aMC_v3_5_13/

# -----------------------------------------------------------------------
# 1. W+jets
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 2. Z+jets
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 3. tt+jets
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 4. tW
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 5. tb
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 6. t+jets
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 7. WW+jets
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 8. WZ+jets
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 9. ttZ
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 10. ttW
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# 11. ttH
# -----------------------------------------------------------------------
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

echo "All background processes done."

