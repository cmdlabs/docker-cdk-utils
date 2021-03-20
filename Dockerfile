FROM alpine:3.13

ENV AWS_CDK_VERSION=1.94.1
ENV AWSCLI_VERSION=1.19.33

RUN apk -v --no-cache --update add \
        nodejs \
        npm \
        python3 \
        py3-pip \
        ca-certificates \
        groff \
        less \
        bash \
        make \
        curl \
        wget \
        zip \
        git \
        openssh-client \
        jq \
        && \
    update-ca-certificates && \
    npm install -g aws-cdk@${AWS_CDK_VERSION} && \
    pip --no-cache-dir install --upgrade awscli==${AWSCLI_VERSION}

VOLUME [ "/root/.aws" ]
VOLUME [ "/work" ]

# Allow for caching python modules
VOLUME ["/usr/lib/python3.7/site-packages/"]

WORKDIR /work

CMD ["cdk", "--version"]