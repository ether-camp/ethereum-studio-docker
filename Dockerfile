############################################################
# Dockerfile to build ide.ether.camp container images
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Alex Sinyagin

ARG c9sdk_branch=master
ARG ethergit_ethereum_sandbox_branch=master
ARG ethergit_solidity_compiler_branch=master
ARG ethergit_libs_branch=master
ARG ethereum_sandbox_branch=master
ARG oraclize_sandbox_plugin_branch=master

# Attach ethereum repository
RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties
RUN add-apt-repository ppa:ethereum/ethereum

RUN apt-get update
RUN apt-get -y install git build-essential zip ca-certificates git-core curl sudo solc tmux

ENV HOME /root

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN  apt-get -y install nodejs

WORKDIR /opt/app
ADD . /opt/app

ENV PATH /usr/local/bin:/opt/local/bin/:$PATH

WORKDIR /root
RUN git clone https://github.com/ether-camp/c9sdk
RUN git clone https://github.com/etherj/c9.ide.collab-patch
RUN git clone https://github.com/ether-camp/c9.ide.test.mocha-patch

WORKDIR /root/c9sdk
RUN git checkout ${c9sdk_branch}
RUN scripts/install-sdk.sh
RUN npm install
RUN scripts/install-ether-camp.sh --ethergit-ethereum-sandbox-branch ${ethergit_ethereum_sandbox_branch} --ethergit-solidity-compiler-branch ${ethergit_solidity_compiler_branch} --ethergit-libs-branch ${ethergit_libs_branch}

WORKDIR /root/c9sdk/plugins/c9.ide.collab
RUN patch -p1 < /root/c9.ide.collab-patch/collab.patch

WORKDIR /root/c9sdk/plugins/c9.ide.test.mocha
RUN patch -p1 < /root/c9.ide.test.mocha-patch/mocha.patch

WORKDIR /root
RUN git clone https://github.com/etherj/ethereum-sandbox.git
WORKDIR /root/ethereum-sandbox
RUN git checkout ${ethereum_sandbox_branch}
RUN npm install

# Oraclize plugin is not publicly available
#RUN npm install git+ssh://git@github.com/oraclize/ethereum-studio-sandbox-plugin.git#${oraclize_sandbox_plugin_branch}

RUN npm -g install forever mocha gulp-cli

WORKDIR /root

# Port mapping
EXPOSE 8181
EXPOSE 8555

ENV VIRTUAL_PORT=8181
ENV PROXY_PORTS=8555,8080,8081,8082

ENV NODE_PATH=$NODE_PATH:/root/.c9/node_modules/

RUN echo "#!/bin/sh" >> run-ide.sh
RUN echo '[ ! "$(ls ./workspace)" ] && git clone https://github.com/ether-camp/example-project.git workspace/example-project' >> run-ide.sh
RUN echo "rm -rf workspace/.c9/collab.* workspace/.c9/metadata" >> run-ide.sh
RUN echo "forever start ethereum-sandbox/app.js" >> run-ide.sh
RUN echo 'node c9sdk/server.js -l 0.0.0.0 ether-camp-$MODE --settings ether-camp-$MODE -w /root/workspace/ -a : > out.log' >> run-ide.sh
RUN chmod +x run-ide.sh

CMD ["/bin/sh", "-c", "./run-ide.sh"]
