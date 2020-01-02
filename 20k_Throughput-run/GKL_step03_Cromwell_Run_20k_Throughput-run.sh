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

source ./configure

WDL=PairedSingleSampleWf_noqc_nocram_optimized.wdl.20k
JSON=$BASEDIR/PairedSingleSampleWf_optimized.inputs
#JSON=$BASEDIR/JSON/PairedSingleSampleWf_optimized.inputs

limit=$NUM_WORKFLOW

export DATE_WITH_TIME=`date "+%Y%m%d:%H-%M-%S"`
mkdir "20k_WF_ID-"$DATE_WITH_TIME""
mkdir "cromwell-status-"$DATE_WITH_TIME""
#remove the temporarary diriectories from previous runs.
rm -rf cromwell-monitor
rm -rf 20k_WF_ID
#creating new temporary directories for monitoring and output results
mkdir cromwell-monitor 
mkdir 20k_WF_ID

curl localhost:8000/api/workflows/v1/query 2>/dev/null | json_pp>"cromwell-status-"$DATE_WITH_TIME""/cromwell_start
cp "cromwell-status-"$DATE_WITH_TIME""/cromwell_start cromwell-monitor

echo Start time is `date`  : `date +"%H:%M:%S"`

export wf_count=0
run_20k(){
	
	total_cores=`lscpu | grep "^CPU(s):" | tr -s ' '| cut -d ':' -f2`
	sed  -i "s#haplotype_scatter_count\": [0-9]#haplotype_scatter_count\":$total_cores#g" ${JSON}.20k.json   
	
	for i in $(seq $limit)
		do
        	echo $i
	        #curl -vXPOST http://$CROMWELL_HOST:8000/api/workflows/v1 -F workflowSource=@${WDL} -F workflowInputs=@${JSON}${i}.20k.json > 20k_submission_response.txt
	        curl -vXPOST http://$CROMWELL_HOST:8000/api/workflows/v1 -F workflowSource=@${WDL} -F workflowInputs=@${JSON}.20k.json > 20k_submission_response.txt
		cat 20k_submission_response.txt |  cut -d '"' -f4 >"20k_WF_ID-"$DATE_WITH_TIME""/20k_WF_ID_${i}.txt
i		cp "20k_WF_ID-"$DATE_WITH_TIME""/20k_WF_ID_* 20k_WF_ID
	        wf_count+=1
		echo $wf_count" "$1" " $2 "==>"`cat 20k_WF_ID-${DATE_WITH_TIME}/20k_WF_ID_${i}.txt` 
		sleep 360
	done
}

run_pair_hmm(){
	#https://github.com/broadinstitute/gatk/blob/master/src/main/java/org/broadinstitute/hellbender/utils/pairhmm/PairHMM.java
 	#array=(EXPERIMENTAL_FPGA_LOGLESS_CACHING)
 	array=(EXACT ORIGINAL LOGLESS_CACHING AVX_LOGLESS_CACHING AVX_LOGLESS_CACHING_OMP FASTEST_AVAILABLE)
	for index in ${!array[*]}; do 
		echo " Running with run_pair_hmm ${array[$index]} "
		sed -i "s#gatk_gkl_pairhmm_implementation\":[A-Z_\",]*#gatk_gkl_pairhmm_implementation\":\"${array[$index]}\",#g"  ${JSON}.20k.json
		run_20k
	done
		sed -i "s#gatk_gkl_pairhmm_implementation\":[A-Z_\",]*#gatk_gkl_pairhmm_implementation\":\"AVX_LOGLESS_CACHING\",#g"  ${JSON}.20k.json
}

run_smith_waterman(){
	#Update based on
	#https://github.com/broadinstitute/gatk/blob/master/src/main/java/org/broadinstitute/hellbender/utils/smithwaterman/SmithWatermanAligner.java
        array=(FASTEST_AVAILABLE AVX_ENABLED JAVA)
        for index in ${!array[*]}; do
                echo " Running with run_pair_hmm ${array[$index]} "
		sed -i "s#compression_level\":[0-9]#compression_level\":\"${array[$index]}\",#g" ${JSON}.20k.json
                run_20k
        done
		sed -i "s#compression_level\":[0-9]#compression_level\":\"AVX_ENABLED\",#g" ${JSON}.20k.json
}


run_compression(){
	for j in {1..9}
 		do
		echo " Running with run_compression ${j} "
		sed -i "s#compression_level\":[0-9]#compression_level\":$j#g" ${JSON}.20k.json
		sleep 5
		run_20k
	done
		sed -i "s#compression_level\":[0-9]#compression_level\":1#g" ${JSON}.20k.json
}

run_threads(){
	for j in {2..4}
        	do
		echo " Running with run_threads ${j} "
	        sed -i "s#gatk_gkl_pairhmm_threads\":[0-9]#gatk_gkl_pairhmm_threads\":$j#g" ${JSON}.20k.json
        	sleep 5
	        run_20k	
	done
	        sed -i "s#gatk_gkl_pairhmm_threads\":[0-9]#gatk_gkl_pairhmm_threads\":1#g" ${JSON}.20k.json
}

run_NGKL(){
	WDL=NGKL-PairedSingleSampleWf_noqc_nocram_optimized.wdl.20k
	JSON=$BASEDIR/NGKL-PairedSingleSampleWf_optimized.inputs
	echo " Running with run_NGKL " 
	run_20k
}

run_compression
run_threads
run_pair_hmm
run_smith_waterman
run_NGKL

bash ./GKL_step05_Output_20k_Throughput-run.sh $wf_count | sort > gkl_run_status`date +"%F"`

