#!/bin/bash

# Conda 설치 및 환경 생성
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

# 환경 생성 및 활성화
source ~/miniconda3/bin/activate
conda create -n myenv python=3.10 -y
conda activate myenv

# 주요 라이브러리 설치
conda install -y numpy pandas matplotlib pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia

