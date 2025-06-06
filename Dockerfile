FROM ubuntu:jammy

# 非 root ユーザーを作成（例: vscode）
ARG USER=vscode
ARG UID
ARG GID
RUN groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# 必要パッケージをインストール
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
   python3 python3-pip bash-completion locales \
&& localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
&& apt-get -y install curl git apt ca-certificates locales openssh-client unzip make vim less gcc build-essential \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Goss install
RUN curl -L https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss
RUN chmod +rx /usr/local/bin/goss

# その他環境変数など
ENV LANG=ja_JP.UTF-8

# ユーザーを切り替え
USER ${USER}

# ssh-keygen のための設定
RUN ssh-keygen -f ~/.ssh/master.ecdsa.key -t rsa -N ""

# ~/.local/bin を PATH に追加する設定を .bashrc に追記
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/${USER}/.bashrc 
RUN echo 'export USER="${USER}"' >> /home/${USER}/.bashrc \
 && echo 'source /etc/bash_completion' >> /home/${USER}/.bashrc

# pip で ansible を --user インストール
RUN python3 -m pip install --user --upgrade pip
RUN python3 -m pip install --user --upgrade setuptools
RUN python3 -m pip install --user flake8 autopep8

WORKDIR /workspaces
COPY ansible_Venv.txt /tmp/
# Install Ansible lint and Ansible
RUN pip3 install -r /tmp/ansible_Venv.txt

# コンテナ起動時に bash を対話モードで開く
SHELL ["/bin/bash", "-lc"]
CMD ["bash"]

# ansibe追加モジュールのインストール
RUN ansible-galaxy collection install community.libvirt
RUN ansible-galaxy collection install community.crypto
RUN ansible-galaxy collection install community.docker --upgrade
RUN ansible-galaxy collection install community.general
RUN ansible-galaxy collection install community.zabbix --upgrade
RUN ansible-galaxy collection install freeipa.ansible_freeipa --upgrade

