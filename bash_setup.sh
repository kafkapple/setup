#!/bin/bash

# 사용자 환경 변수
echo "alias ll='ls -alF'" >> ~/.bashrc
echo "export PROJECT_DIR=~/my_project" >> ~/.bashrc
echo "export DATA_DIR=~/my_data" >> ~/.bashrc

# 적용
source ~/.bashrc

