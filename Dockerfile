FROM ubuntu:20.04

RUN apt update && apt install --yes python3-pip git make

RUN useradd -m gortdoc

RUN pip3 install sphinx sphinx-rtd-theme Pygments 

WORKDIR /docs


