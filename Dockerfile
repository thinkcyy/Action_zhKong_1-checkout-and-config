# Container image that runs your code
FROM ubuntu:22.04

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Asia/Shanghai
#RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
