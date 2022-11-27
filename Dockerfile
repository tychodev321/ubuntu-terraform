FROM registry.access.redhat.com/ubi9/ubi-minimal:9.0.0
# FROM redhat/ubi9/ubi-minimal:9.0.0

LABEL maintainer=""

ENV TERRAFORM_VERSION=1.2.2
ENV TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 

ENV AWSCLI_VERSION=2.7.7
ENV AWSCLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip

ENV KUBECTL_VERSION=v1.24.1
ENV KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV KUBECTL_CHECKSUM_URL=https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256

# MicroDNF is recommended over YUM for Building Container Images
# https://www.redhat.com/en/blog/introducing-red-hat-enterprise-linux-atomic-base-image

RUN microdnf update -y \
    && microdnf install -y unzip \
    && microdnf install -y wget \
    && microdnf install -y git \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Download and install Terraform
RUN wget ${TERRAFORM_URL} \ 
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/bin/terraform

# Download and install AWS CLI
RUN curl ${AWSCLI_URL} -o "awscliv2.zip" \ 
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local -b /usr/local/bin -u \
    && rm  -rf awscliv2.zip awscliv2

# Download and install Kubectl
RUN curl -LO "${KUBECTL_URL}" \
    && curl -LO "${KUBECTL_CHECKSUM_URL}" \
    && echo "$(<kubectl.sha256) kubectl" | sha256sum --check \
    && chmod +x kubectl \
    && mv ./kubectl /usr/bin//kubectl

RUN terraform --version \
    && aws --version \
    && kubectl version --client \
    && git --version

# USER 1001

CMD ["echo", "This is a 'Purpose Built Image', It is not meant to be ran directly"]
