FROM ubuntu
LABEL maintainer="yasin"
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install nano
RUN apt-get install -y python3 python3-pip
COPY . /app
WORKDIR /app
EXPOSE 5000
# ENTRYPOINT echo "Hello World" bu yazildiktan sonra container exited moda gecer
# bash kapanana kadar container calismaya devam eder
ENTRYPOINT ["bash"]     