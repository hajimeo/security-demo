FROM ubuntu:20.04

# To specify Nexus apt and pypi proxy repositories (if not reachable, will be just ignored):
ENV _NXRM_APT_PROXY="http://dh1.standalone.localdomain:8081/repository/apt-proxy/"
# To use apt proxy for below apt-get commands, use below sed (other apt commands in setup.sh uses above env variable):
RUN sed -i.bak "s@http://archive.ubuntu.com/ubuntu/@${_NXRM_APT_PROXY%/}/@g" /etc/apt/sources.list

RUN apt-get update && apt-get install -y init curl
RUN curl -sf -L --compressed "https://raw.githubusercontent.com/hajimeo/security-demo/main/scripts/setup.sh" -o /tmp/setup.sh && bash -x /tmp/setup.sh
RUN rm -rf /var/lib/apt/lists/* /tmp/*