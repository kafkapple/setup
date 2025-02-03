#!/bin/bash

# Nvidia 드라이버 설치
sudo apt update
sudo ubuntu-drivers autoinstall
# CUDA 설치 (CUDA 11.8 예시)
wget https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_550.54.15_linux.run
chmod +x cuda_12.4.1_550.54.15_linux.run
sudo sh cuda_12.4.1_550.54.15_linux.run
# 환경 변수 설정
echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH" >> ~/.bashrc

# 적용
source ~/.bashrc

