- Please Strictly follow the following instructions for to setup Madgraph

- Step 1 : Download this specific mg5 configuration and unzip it `wget https://launchpad.net/mg5amcnlo/3.0/3.6.x/+download/MG5_aMC_v3.5.13.tar.gz`
- Step 2 : Create a conda environment of python 3.11 and root installed using conda-forge using the following command `conda create -n madgraph python=3.11 root -c conda-forge`
- Step 3 : Install Pythia and Delphes via Madgraph
- Step 4 : Run a test run - if you get a histogram related error exit the madgraph and run the following command ` export PYTHIA8DATA='' `
- Step 5 : If you are having issues with lhapdf - change the pdf label inside the default run_card to `nn23lol`
