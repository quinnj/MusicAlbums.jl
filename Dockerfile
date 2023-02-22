FROM julia:1.8.5-bullseye

RUN apt-get update && apt-get install -y gcc
ENV JULIA_PROJECT @.
WORKDIR /home

ENV VERSION 1
ADD . /home

RUN julia deploy/packagecompile.jl

EXPOSE 8080

ENTRYPOINT ["julia", "-JMusicAlbums.so", "-t", "2", "-e", "MusicAlbums.run();"]