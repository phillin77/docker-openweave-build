FROM ubuntu:18.04

# Install gnu
RUN apt-get update && apt-get install -y gnupg2

# Install toolchain and dependencies
RUN apt-key update && \
apt-get update && \
apt-get install -y autotools-dev build-essential automake libtool git lcov \
                    libdbus-1-dev libglib2.0-dev libssl-dev libudev-dev \
                    bridge-utils make net-tools software-properties-common \
                    python2.7 python-setuptools python-lockfile python-psutil && \
apt-get install -y --allow gcc-arm-none-eabi && \
apt-get update -qq && \
apt-get clean all

# Get the source code & Install Happy and OpenWeave
# Note: no need to use sudo in Docker (replace it in Makefile used by Happy)
RUN mkdir -p /openweave && \
cd /openweave && \
git clone https://github.com/openweave/happy.git && \
git clone https://github.com/openweave/openweave-core.git && \
cd /openweave/happy && \
sed -e 's/sudo//g' ./Makefile > ./Makefile.tmp && rm -f ./Makefile && mv ./Makefile.tmp ./Makefile && \
sed -e 's/=sudo/=/g' ./bin/Makefile > ./bin/Makefile.tmp && rm -f ./bin/Makefile && mv ./bin/Makefile.tmp ./bin/Makefile && \
make && \
cd /openweave/openweave-core && \
make -f Makefile-Standalone

# Configure Happy with OpenWeave
RUN happy-configuration weave_path /openweave/openweave-core/build/x86_64-unknown-linux-gnu/src/test-apps

RUN export PATH=$PATH:/openweave/openweave-core/src/test-apps/happy/bin

WORKDIR /openweave
