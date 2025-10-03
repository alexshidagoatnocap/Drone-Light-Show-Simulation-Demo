FROM python:slim

WORKDIR /home/root
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    tmux \
    python3-venv \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Build SITL
RUN git clone  https://github.com/alexshidagoatnocap/ardupilot \ 
    && cd ardupilot \
    && git checkout CMCopter-4.6 \
    && git submodule update --init --recursive 
    # # Replace all occurrences of -dead-strip with --dead_strip for Linux compatibility
    # && find . -type f -exec sed -i 's/-dead-strip/--dead_strip/g' {} + 

RUN cd ardupilot \
    && python3 -m venv .venv \
    && source .venv/bin/activate \
    # && cd modules \
    # && rm -r libskybrush \
    # && git clone https://github.com/skybrush-io/libskybrush \
    # && cd .. \
    && pip install -U pip wheel setuptools \
    && pip install dronecan \
    && pip install empy==3.3.4 \
    && pip install future intelhex pexpect \
    && ./waf configure --debug --board sitl \
    && ./waf copter \
    && deactivate 

# Build Skybrush Server
RUN git clone https://github.com/alexshidagoatnocap/skybrush-server \
    && pip3 install uv \
    && cd skybrush-server \
    && uv sync 

# Build Swarm Launcher
RUN git clone https://github.com/alexshidagoatnocap/ap-swarm-launcher \
    && cd ap-swarm-launcher \
    && uv sync