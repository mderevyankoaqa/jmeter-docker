FROM alpine:3.18.4

# Init JMeter & tools
ARG JMETER_VERSION="5.6.2"
ARG CMDRUNNER_VERSION="2.3"
ARG JMETER_PMANAGER_VERSION="1.9"
ARG JMETER_PLUGINS="jpgc-csl=0.1,jpgc-casutg=2.10"

# Setup test settings
ARG JMETER_RESULTS_FOLDER="/opt/test_results"
ARG JMETER_SCRIPTS_FOLDER="/opt/scripts"
ARG JMETER_TEST_SCRIPT="smoke.jmx"
ARG JMETER_TEST_SETTINGS="smoke.properties"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_CUSTOM_PLUGINS_FOLDER /plugins
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_RESULTS ${JMETER_RESULTS_FOLDER}
ENV JMETER_SCRIPTS ${JMETER_SCRIPTS_FOLDER}
ENV JMETER_TEST_SCRIPT_NAME ${JMETER_TEST_SCRIPT}
ENV JMETER_TEST_SETTINGS_NAME ${JMETER_TEST_SETTINGS}

# Install extra packages
# Set TimeZone, See: https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-612751142
ARG TZ="Europe/Kiev"
ENV TZ ${TZ}
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk16-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# Install plugins
RUN wget https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/${JMETER_PMANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PMANAGER_VERSION}.jar \
  && mv ./jmeter-plugins-manager-${JMETER_PMANAGER_VERSION}.jar ${JMETER_HOME}/lib/ext \
  && wget https://repo1.maven.org/maven2/kg/apc/cmdrunner/${CMDRUNNER_VERSION}/cmdrunner-${CMDRUNNER_VERSION}.jar \
  && mv ./cmdrunner-${CMDRUNNER_VERSION}.jar ${JMETER_HOME}/lib \
  && java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PMANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
  && ${JMETER_HOME}/bin/PluginsManagerCMD.sh install ${JMETER_PLUGINS}

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Copy JMeter test scripts and data
COPY src/ ${JMETER_SCRIPTS_FOLDER}/

# Entrypoint start the JMeter test
COPY entrypoint.sh /

# Setup work dir
WORKDIR	${JMETER_HOME}

# Creatre dir to map the test results
RUN mkdir ${JMETER_RESULTS_FOLDER}

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]