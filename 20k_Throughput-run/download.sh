
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

wget -nc -v -P $BASEDIR https://github.com/broadinstitute/warp/releases/download/WholeGenomeGermlineSingleSample_v2.3.3/WholeGenomeGermlineSingleSample_v2.3.3.wdl
wget -nc -v -P $BASEDIR https://github.com/broadinstitute/warp/releases/download/WholeGenomeGermlineSingleSample_v2.3.3/WholeGenomeGermlineSingleSample_v2.3.3.zip
wget -nc -v -P $BASEDIR https://github.com/broadinstitute/warp/releases/download/WholeGenomeGermlineSingleSample_v2.3.3/WholeGenomeGermlineSingleSample_v2.3.3.options.json


# To fetch latest 
#wget https://github.com/broadinstitute/warp/releases/download/WholeGenomeGermlineSingleSample_develop/WholeGenomeGermlineSingleSample_develop.wdl
#wget https://github.com/broadinstitute/warp/releases/download/WholeGenomeGermlineSingleSample_develop/WholeGenomeGermlineSingleSample_develop.zip
#wget https://github.com/broadinstitute/warp/releases/download/WholeGenomeGermlineSingleSample_develop/WholeGenomeGermlineSingleSample_develop.options.json

