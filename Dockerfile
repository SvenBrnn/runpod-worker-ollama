FROM atcr.io/neutrino2211.bsky.social/qrk-inflect:latest

ENV PYTHONUNBUFFERED=1

# Set up the working directory
WORKDIR /

RUN apt-get update --yes --quiet && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    software-properties-common \
    gpg-agent \
    build-essential apt-utils \
    && apt-get install --reinstall ca-certificates \
    && add-apt-repository --yes ppa:deadsnakes/ppa && apt update --yes --quiet \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-lib2to3 \
    python3.11-gdbm \
    python3.11-tk \
    bash \
    curl && \
    ln -s /usr/bin/python3.11 /usr/bin/python && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /work

# Add my src as /work
ADD ./src /work

# Install runpod and its dependencies
RUN pip install -r requirements.txt && chmod +x /work/start.sh
LABEL org.opencontainers.image.title="Inflect Runpod Worker" \
    org.opencontainers.image.description="Inflect Runpod Worker - runpod docker image docker and docker-compose for complex LLM based systems"

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "-c", "/work/start.sh"]
