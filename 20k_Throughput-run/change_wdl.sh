
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $BASEDIR

# sudo yum install -y R

# Create generic symlinks for tools e.g. :
for tool in bwa samtools gatk; do export tool_version=`ls $GENOMICS_PATH/tools | grep ${tool}- | head -n1` && echo ${tool_version} && ln -sfn $GENOMICS_PATH/tools/$tool_version $GENOMICS_PATH/tools/$tool; done;

# Clean up
rm -rf $BASEDIR/*.wdl
rm -rf $BASEDIR/warp.zip

# Download WGS release from WARP
bash $BASEDIR/download.sh

# Fix WDL
unzip -d $BASEDIR/ $BASEDIR/WholeGenomeGermlineSingleSample*.zip
# grep -n -E 'picard|docker|disk|preemp|VerifyBamID|gatk|gitc|usr' $BASEDIR/*.wdl > $BASEDIR/changes.txt

echo "Commenting variables"
#sed -i 's|Int disk_size|#Int disk_size|g' $BASEDIR/*.wdl
sed -i  's|Int pre|#Int pre|g' $BASEDIR/*.wdl
sed -i 's|Int agg_preemptible_|#Int agg_preemptible_|g'  $BASEDIR/*.wdl
sed -i 's|preemptible:|#preemptible:|g' $BASEDIR/*.wdl
sed -i 's|disks:|#disks:|g' $BASEDIR/*.wdl
sed -i 's| preemptible_tries =| #preemptible_tries =|g' $BASEDIR/*.wdl
sed -i 's|agg_preemptible_tries =|#agg_preemptible_tries =|g' $BASEDIR/*.wdl

echo "Changing tool_path"
sed -i 's|gatk --java|${tool_path}/gatk/gatk --java|g' $BASEDIR/*.wdl
sed -i 's|use_gatk3_haplotype_caller = true|use_gatk3_haplotype_caller = false|g' $BASEDIR/*.wdl
sed -i 's|samtools |${tool_path}/samtools/samtools |g' $BASEDIR/*.wdl
sed -i 's|seq_cache_populate\.pl |${tool_path}/samtools/misc/seq_cache_populate\.pl |g' $BASEDIR/*.wdl
sed -i 's|/usr/gitc/VerifyBamID|${tool_path}/VerifyBamID/bin/VerifyBamID |g' $BASEDIR/BamProcessing.wdl

sed -i 's|/usr/gitc/bwa|${tool_path}/bwa/bwa|g' $BASEDIR/*.wdl
sed -i 's|/usr/gitc/~{bwa_commandline}|${tool_path}/bwa/~{bwa_commandline}|g' $BASEDIR/*.wdl

echo "Changing picard"
sed -i  's|/usr/picard/picard.jar|${tool_path}/picard.jar|g' $BASEDIR/*.wdl
sed -i  's|/usr/gitc/picard-private.jar|${tool_path}/picard.jar|g' $BASEDIR/*.wdl
sed -i  's|/usr/gitc/picard.jar|${tool_path}/picard.jar|g' $BASEDIR/*.wdl

echo "Changing docker gatk"
sed -i 's|docker:|#docker:|g' $BASEDIR/*.wdl
sed -i  's|String gatk_docker|#String gatk_docker|g' $BASEDIR/*.wdl
sed -i 's|bootDiskSizeGb:|#bootDiskSizeGb:|g' $BASEDIR/*.wdl

# remove disk_size variable from germline
sed -i '283,288d' $BASEDIR/GermlineVariantDiscovery.wdl

# Verify Output for UnmappedBamToAlignedBam/$WF_ID/call-CheckContamination/execution/NA1278.preBqsr.selfSM
#export num_freemix=`grep -n FREEMIX $BASEDIR/BamProcessing.wdl | grep print | cut -d ':' -f1`
#sed -i $num_freemix'd'  $BASEDIR/BamProcessing.wdl
#sed -i $num_freemix'i \          print(float(row["FREEMIX(alpha)"])/~{contamination_underestimation_factor})'  $BASEDIR/BamProcessing.wdl

echo "Replace tool_path"
source $BASEDIR/configure
sed -i 's|\${tool_path}|'$GENOMICS_PATH'/tools|g' $BASEDIR/*.wdl
sed -i '44i \    String tool_path = "'${GENOMICS_PATH}'/tools"'  $BASEDIR/WholeGenomeGermlineSingleSample_*.wdl

echo " Create import WDLs zip"
zip -j  $BASEDIR/warp.zip $BASEDIR/*.wdl
rm -rf $BASEDIR/[A-V]*.wdl
mv $BASEDIR/WholeGenomeGermlineSingleSample_*.wdl $BASEDIR/WholeGenomeGermlineSingleSample.wdl

# Usage : Test pipeline
#sudo -u cromwell curl -vXPOST http://127.0.0.1:8000/api/workflows/v1 -F workflowSource=@$BASEDIR/WholeGenomeGermlineSingleSample.wdl -F workflowInputs=@$BASEDIR/WholeGenomeGermlineSingleSample_20k.json -F workflowDependencies=@$BASEDIR/warp.zip
#sleep 10 
#curl -vXGET $CROMWELL_HOST:8000/api/workflows/v1/query?status=Running | json_pp | jq .results | jq '.[] | (.id +" | " + .status + " | " + .start + " | "+ .submission + "|" + .rootWorkflowId )'
