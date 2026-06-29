FROM ubuntu
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install nano
RUN mkdir /data
WORKDIR /data
RUN echo "docker file example volume" > test.txt
VOLUME /data
