FROM julia:1.5.0-rc1-buster

ENV JULIA_PROJECT @.
WORKDIR /home

ENV VERSION 1
ADD . /home

RUN julia deploy/packagecompile.jl

EXPOSE 8080

ENTRYPOINT ["julia", "-JMusicAlbums.so", "-e", "MusicAlbums.run(\"test/albums2.sqlite\", \"resource/authkeys.json\")"]