FROM ubuntu:22.04

WORKDIR /home/root
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3 \
    python3-pip \
    wget \
    tmux \
    python3-venv \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \  
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Update Python to 3.11.3 (Required for building the SITL)
RUN wget https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tgz \
    && tar -xzf Python-3.11.3.tgz \
    && cd Python-3.11.3 \
    && ./configure --enable-optimizations \
    && make -j 12 \
    && make altinstall \
    && update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1 \
    && cd .. \
    && rm -rf Python-3.11.3 \
    && rm  Python-3.11.3.tgz \
    && cd ~

# Build SITL
RUN git clone https://github.com/alexshidagoatnocap/ardupilot \ 
    && cd ardupilot \
    && git checkout CMCopter-4.2 \
    && git submodule update --init --recursive \
    && python3 -m venv .venv \
    && source .venv/bin/activate \
    && pip install -U pip wheel \
    && pip install future empy intelhex pexpect \
    && ./waf configure --debug --board sitl \
    && ./waf copter \
    && deactivate \
    && cd ~

# Build Skybrush Server
RUN git clone https://github.com/alexshidagoatnocap/skybrush-server \
    && pip3 install uv \
    && cd skybrush-server \
    && uv sync \
    && cd ~

# Build Swarm Launcher
RUN git clone https://github.com/alexshidagoatnocap/ap-swarm-launcher \
    && cd ap-swarm-launcher \
    && uv sync

# TODO: Look into multi-stage builds for a build and release image, this could help reduce the final image size
# Look into using a lightweight image such as alpine