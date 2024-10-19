#https://baccini-al.medium.com/how-to-containerize-a-github-actions-self-hosted-runner-5994cc08b9fb
FROM ubuntu:20.04

ARG RUNNER_VERSION="2.320.0"

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    useradd -m docker && \
    apt-get install -y --no-install-recommends \
    curl \
    tar \
    jq \
    sudo \
    python3-pip \
    python3-dev \
    python3 \
    libssl-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*


# Download and install the GitHub Actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz --retry 3 \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Copy the startup script
COPY start.sh start.sh
RUN sudo chmod +x start.sh

USER docker

# Start the runner
CMD ["./start.sh"]