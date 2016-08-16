
###
# Build via:
#   docker build -t 981971132015.dkr.ecr.us-east-1.amazonaws.com/healthfidelity/rabbitmq:YYYYMMDDa .


FROM ubuntu:15.10

RUN \
  apt-get update \
  && apt-get install --fix-missing -y \
    rabbitmq-server

COPY docker-entrypoint.sh /

EXPOSE 4369 5671 5672 15671 15672 25672
CMD ["rabbitmq-server"]

ENTRYPOINT ["/docker-entrypoint.sh"]
