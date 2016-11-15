
###
# Build via:
#   docker build -t 981971132015.dkr.ecr.us-east-1.amazonaws.com/healthfidelity/rabbitmq:YYYYMMDDa .


FROM ubuntu:15.10

RUN \
  apt-get update \
  && apt-get install -y python-pip python-dev sudo \
  && pip install credstash \
  && apt-get install --fix-missing -y \
    rabbitmq-server

# Make sure the 'ubuntu' user has sudo privileges:
RUN \
  useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
  echo "ubuntu:changeme" | chpasswd && \
  echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  sed -i s#/home/ubuntu:/bin/false#/home/ubuntu:/bin/bash# /etc/passwd

COPY docker-entrypoint.sh /

EXPOSE 4369 5671 5672 15671 15672 25672
CMD ["rabbitmq-server"]

#USER ubuntu

ENTRYPOINT ["/docker-entrypoint.sh"]
