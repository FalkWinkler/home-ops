# You can pick any Debian/Ubuntu-based image. 😊
FROM mcr.microsoft.com/devcontainers/base:bullseye

COPY library-scripts/*.sh /tmp/library-scripts/

ARG KUBECTX_VERSION=0.9.4
ARG K9S_VERSION=0.26.7
ARG GITOPS_VERSION=0.19.0
ARG CILIUM_CLI_VERSION=v0.14.5
ARG CLUSTERCTL_VERSION=1.4.2

# [Option] Install zsh
ARG INSTALL_ZSH="false"
# [Option] Upgrade OS packages to their latest versions
ARG upgradePackages="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# Enable Backports for age
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" > /etc/apt/sources.list.d/backports.list

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get install -y \
        libssl-dev \
        libffi-dev \
        python3-dev \
        python3-pip \
        age \
        ipcalc \
        jq \
        direnv \
        sshpass \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

 # k9s
RUN curl -fsSL "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin k9s \
    # gitops
    && curl -fsSL "https://github.com/weaveworks/weave-gitops/releases/download/v${GITOPS_VERSION}/gitops-linux-x86_64.tar.gz" | tar xz -C /usr/local/bin gitops

# install cilium
RUN curl -fsSL https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz | tar -xz -C /usr/local/bin cilium

# krew plugin
RUN curl -fsSL -o /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" \
    && tar zxvf /tmp/krew.tar.gz -C /tmp \
    && mv /tmp/krew-linux_amd64 /usr/local/bin/krew \
    && chmod +x /usr/local/bin/krew


# install kubestr
RUN curl -fsSL https://github.com/kastenhq/kubestr/releases/download/v0.4.37/kubestr_0.4.37_Linux_amd64.tar.gz  | tar -xz -C /usr/local/bin kubestr

# install kube-rook-ceph
RUN curl -fsSL https://github.com/rook/kubectl-rook-ceph/releases/download/v0.5.2/kubectl-rook-ceph_v0.5.2_linux_amd64.tar.gz  | tar -xz -C /usr/local/bin kubectl-rook-ceph

# install cloudflared
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64  -o /usr/local/bin/cloudflared

# clusterctl
RUN curl -L "https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-linux-amd64" -o clusterctl \
    && chmod +x ./clusterctl \
    && mv ./clusterctl /usr/local/bin/clusterctl

# Cloud Native PostgreSQL plugin for kubectl
RUN curl -sSfL https://github.com/EnterpriseDB/kubectl-cnp/raw/main/install.sh | sudo sh -s -- -b /usr/local/bin

# krew plugin
RUN curl -fsSL -o /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" \
    && tar zxvf /tmp/krew.tar.gz -C /tmp \
    && mv /tmp/krew-linux_amd64 /usr/local/bin/krew

# talos
RUN curl -sL https://talos.dev/install | sh

# taloshelper
RUN curl https://i.jpillora.com/budimanjojo/talhelper! | sudo bash

# Install Doppler CLI
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add - && \
    echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler


# Download and Install the latest packer (AMD64)
RUN PACKER_VERSION=$(curl -sSL https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r -M ".current_version") \
    && wget -nv -O packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && wget -nv -O packer.sha256 https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS \
    && wget -nv -O packer.sha256.sig https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS.sig \
    && curl -s https://keybase.io/hashicorp/pgp_keys.asc | gpg --import \
    && gpg --verify packer.sha256.sig packer.sha256 \
    && echo $(grep -Po "[[:xdigit:]]{64}(?=\s+packer_${PACKER_VERSION}_linux_amd64.zip)" packer.sha256) packer.zip | sha256sum -c \
    && unzip packer.zip \
    && mv packer /usr/local/bin \
    && chmod a+x /usr/local/bin/packer \
    && rm -f packer packer.zip packer.sha256 packer.sha256.sig \
    && unset PACKER_VERSION

# Install Ansible
RUN pip3 install ansible[azure]

# [Option] Install Azure CLI
ARG INSTALL_AZURE_CLI="false"
# [Option] Install Docker CLI
ARG INSTALL_DOCKER="true"
# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="lts/*"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
RUN if [ "${INSTALL_AZURE_CLI}" = "true" ]; then bash /tmp/library-scripts/azcli-debian.sh; fi \
    && if [ "${NODE_VERSION}" != "none" ]; then bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}"; fi \
    && if [ "${INSTALL_DOCKER}" = "true" ]; then \
        bash /tmp/library-scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    else \
        echo '#!/bin/bash\n"$@"' > /usr/local/share/docker-init.sh && chmod +x /usr/local/share/docker-init.sh; \
    fi \
    && rm -rf /var/lib/apt/lists/*

    # install kubectl plugins
RUN krew install krew \
    && krew install ns \
    && krew install ctx \
    && krew install cnpg \
    && krew install volsync

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
