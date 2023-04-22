FROM ubuntu:22.10

LABEL maintainer=""

ENV TERRAFORM_VERSION=1.3.5
ENV TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 

ENV AWSCLI_VERSION=2.9.1
ENV AWSCLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip

ENV KUBECTL_VERSION=1.25.4
ENV KUBECTL_URL=https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV KUBECTL_CHECKSUM_URL=https://dl.k8s.io/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256

RUN apt update -y && apt upgrade -y \
    && apt install -y unzip \
    && apt install -y wget \
    && apt install -y wget \
    && apt install -y git \
    && apt install -y curl \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

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
    # && echo "$(<kubectl.sha256) kubectl" | sha256sum --check \
    && chmod +x kubectl \
    && mv ./kubectl /usr/bin//kubectl

RUN echo "terraform version: $(terraform --version | head -n 1)" \
    && echo "aws-cli version: $(aws --version)" \
    && echo "wget version: $(wget --version | head -n 1)" \
    && echo "unzip version: $(unzip -v | head -n 1)" \
    && echo "git version: $(git --version)" \
    && echo "kubectl version: $(kubectl version --client)"

# USER 1001

CMD ["echo", "This is a 'Purpose Built Image', It is not meant to be ran directly"]
