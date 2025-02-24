#!/bin/bash

# 스크립트 실행 중 오류 발생 시 즉시 종료
set -e

# 함수: 오류 메시지 출력 후 종료
function error_exit {
    echo "에러: $1" >&2
    exit 1
}

# 함수: 패키지 설치
function install_package {
    echo "Installing $1..."
    apt install -y "$1" || error_exit "$1 설치 실패"
}

# 루트 권한 확인
if [ "$EUID" -ne 0 ]; then
    error_exit "이 스크립트는 루트 권한으로 실행되어야 합니다. 'sudo ./setup_server.sh' 형식으로 실행해주세요."
fi

echo "=============================="
echo "  기본 Linux 서버 설정 시작  "
echo "=============================="

# 시스템 패키지 목록 업데이트
echo "시스템 패키지 목록 업데이트 중..."
apt update -y || error_exit "apt update 실패"
apt upgrade -y || error_exit "apt upgrade 실패"

# 필수 패키지 설치
PACKAGES=(
    "git"
    "default-jdk"
    "htop"
    "nvtop"
    "vim"
    "nano"
    "curl"
    "wget"
    "tmux"
    "net-tools"
    "build-essential"
)

for package in "${PACKAGES[@]}"; do
    install_package "$package"
done

echo "기본 패키지 설치 완료."
echo ""

echo "=============================="
echo "        Conda 설정 시작        "
echo "=============================="

# 현재 사용자 설정
CURRENT_USER="${SUDO_USER:-root}"
echo "Conda 설정을 위해 사용자 '$CURRENT_USER'로 전환합니다."

# Conda 설정 스크립트
CONDA_SETUP=$(cat <<'EOF'
set -e
CONDA_PATH="/opt/conda/bin/conda"

if [ ! -f "$CONDA_PATH" ]; then
    echo "에러: $CONDA_PATH 에서 conda를 찾을 수 없습니다."
    exit 1
fi

echo "Conda 초기화 중..."
$CONDA_PATH init
eval "$($CONDA_PATH shell.bash hook)"
source ~/.bashrc

# 기본 환경 설정
$CONDA_PATH config --set auto_activate_base false
$CONDA_PATH config --set channel_priority strict

echo "Conda가 성공적으로 초기화되었습니다."
EOF
)

# Conda 설정 실행
TEMP_SCRIPT="/tmp/setup_conda_temp.sh"
echo "$CONDA_SETUP" > "$TEMP_SCRIPT"
chmod +x "$TEMP_SCRIPT"

if [ "$CURRENT_USER" != "root" ]; then
    sudo -u "$CURRENT_USER" bash "$TEMP_SCRIPT" || error_exit "Conda 설정 실패"
else
    bash "$TEMP_SCRIPT" || error_exit "Conda 설정 실패"
fi
rm -f "$TEMP_SCRIPT"

echo "=============================="
echo "        Conda 설정 완료       "
echo "=============================="

echo "=============================="
echo "        Git 설정 시작         "
echo "=============================="

# Git 설정 스크립트
GIT_SETUP=$(cat <<'EOF'
# Git 사용자 정보 입력
read -p "Git 사용자 이름을 입력하세요: " GIT_USERNAME
read -p "Git 사용자 이메일을 입력하세요: " GIT_USEREMAIL

# Git 글로벌 설정
git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_USEREMAIL}"
git config --global core.editor vim
git config --global core.pager 'less -R'
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# GitHub Personal Access Token 설정
read -s -p "GitHub Personal Access Token (PAT)을 입력하세요: " PAT
echo

# PAT를 credentials 파일에 저장
echo "https://${GIT_USERNAME}:${PAT}@github.com" > ~/.git-credentials
git config --global credential.helper store

echo "Git 설정이 완료되었습니다!"
EOF
)

# Git 설정 실행
GIT_TEMP_SCRIPT="/tmp/setup_git_temp.sh"
echo "$GIT_SETUP" > "$GIT_TEMP_SCRIPT"
chmod +x "$GIT_TEMP_SCRIPT"

if [ "$CURRENT_USER" != "root" ]; then
    sudo -u "$CURRENT_USER" bash "$GIT_TEMP_SCRIPT" || error_exit "Git 설정 실패"
else
    bash "$GIT_TEMP_SCRIPT" || error_exit "Git 설정 실패"
fi
rm -f "$GIT_TEMP_SCRIPT"

echo "=============================="
echo "          Git 설정 완료        "
echo "=============================="

# 시스템 정보 요약
echo -e "\n시스템 정보 요약:"
echo "=============================="
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo "Kernel: $(uname -r)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $2}')"
echo "=============================="

echo "설정이 완료되었습니다. 변경 사항을 적용하려면 다음 명령을 실행하세요:"
echo "source ~/.bashrc"

#chmod +x setup_server_v2.sh
# bash setup_server_v2.sh