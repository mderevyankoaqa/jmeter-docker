#!/bin/bash
# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#

# Install jmeter plugins available on /plugins volume
if [ -d $JMETER_CUSTOM_PLUGINS_FOLDER ]
then
    for plugin in ${JMETER_CUSTOM_PLUGINS_FOLDER}/*.jar; do
        cp $plugin ${JMETER_HOME}/lib/ext
    done;
fi

# Execute JMeter command
set -e
freeMem=`awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo`

[[ -z ${JVM_XMN} ]] && JVM_XMN=$(($freeMem/10*2))
[[ -z ${JVM_XMS} ]] && JVM_XMS=$(($freeMem/10*8))
[[ -z ${JVM_XMX} ]] && JVM_XMX=$(($freeMem/10*8))

export JVM_ARGS="-Xmn${JVM_XMN}m -Xms${JVM_XMS}m -Xmx${JVM_XMX}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS=-Dlog4j2.formatMsgNoLookups=true
echo "jmeter ALL ARGS=${EXTRA_ARGS} $@"


echo prepare infrastrcuture
echo create result folder
path=/opt/scripts
now=$(date +%Y%m%d_%H%M%S)
resultFolderName=${JMETER_RESULTS}/load_test_$now
mkdir -p $resultFolderName
echo $resultFolderName is created
echo create Reports folder
reportFolderName=$resultFolderName/report
reportTmpFolderName=$resultFolderName/report_tmp
mkdir -p $reportFolderName
echo $reportFolderName has created
mkdir -p $reportTmpFolderName
echo $reportTmpFolderName has created
jmeterScriptpath=$path/init.jmx
jmeterResultFilePath=$resultFolderName/results.jtl
jmeterLogFilePath=$resultFolderName/logs.txt
echo jmeterResultFilePath is $jmeterResultFilePath
echo jmeterLogFilePath is $jmeterLogFilePath
echo start Jmeter script
jmeter ${EXTRA_ARGS} $@ -n -t $jmeterScriptpath -l $jmeterResultFilePath -j $jmeterLogFilePath -Dserver.rmi.ssl.disable=true -Jjmeter.reportgenerator.temp_dir=$reportTmpFolderName -e -o $reportFolderName
echo "END Running Jmeter on `date`"