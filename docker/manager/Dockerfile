FROM node:6.14

VOLUME ["/opt/synthea/manager"]

RUN mkdir -p /opt/synthea/manager

WORKDIR /opt/synthea/manager

ENTRYPOINT [ "/opt/synthea/manager/compile.sh", "devdeploy" ]