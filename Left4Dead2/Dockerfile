# Left4Dead2 Server repo
#
# VERSION 0.1

FROM ubuntu
MAINTAINER bfosberry

RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y install gdb mailutils postfix lib32gcc1 expect wget

ENV USERNAME l4d2server
RUN adduser --disabled-password --gecos "" $USERNAME
RUN usermod -a -G sudo $USERNAME
ENV HOME /home/$USERNAME

ADD ./l4d2server_automated /home/l4d2server/
RUN chmod +x /home/l4d2server/l4d2server_automated
RUN chown l4d2server /home/l4d2server/l4d2server_automated

USER l4d2server
WORKDIR /home/l4d2server
RUN ./l4d2server_automated install
