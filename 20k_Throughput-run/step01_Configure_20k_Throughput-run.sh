#! /bin/bash
# Copyright (c) 2019 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License"); # you may not use this file except in compliance with the License.
# You may obtain a copy of the License at #
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software # distributed under the License is distributed on an "AS IS" BASIS, # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and # limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#

###########Editing JSON file#############
source ./configure

#datapath is the existing path specified in the 20k_WholeGenomeGermlineSingleSample.json.Do not edit this path
datapath=/mnt/lustre/genomics/data
#toolspath is the existing path specified in the 20k_WholeGenomeGermlineSingleSample.json.Do not edit this path
toolspath=/mnt/lustre/genomics/tools

mkdir -p  $BASEDIR/JSON
cd $BASEDIR/JSON
cp $BASEDIR/20k_WholeGenomeGermlineSingleSample.json $BASEDIR/JSON/20k_WholeGenomeGermlineSingleSample.json

newdatapath=${DATA_PATH}
newtoolspath=${TOOLS_PATH}

#pointing the correct data path to wdl
sed -i "s%$datapath%$newdatapath%g" $BASEDIR/JSON/20k_WholeGenomeGermlineSingleSample.json
sed -i "s%$toolspath%$newtoolspath%g" $BASEDIR/JSON/20k_WholeGenomeGermlineSingleSample.json

limit=$NUM_WORKFLOW

for i in $(seq $limit)
do

   cp 20k_WholeGenomeGermlineSingleSample.json 20k_WholeGenomeGermlineSingleSample_${i}.json
   sed -i "s@genomics-public-data@genomics-public-data$i@g" 20k_WholeGenomeGermlineSingleSample_${i}.json
done

############Editing WDL file##################
#user may either edit the tool versions in the WDL file or create symlinks to each tool and add the symlink to the WDL

