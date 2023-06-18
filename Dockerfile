FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
# https://dockr.ly/3e57aTq

# encoding
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN echo "export http_proxy=http://127.0.0.1:7890" >> ~/.bashrc
RUN echo "export https_proxy=http://127.0.0.1:7890" >> ~/.bashrc

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  apt-get clean

# fix (tzdata)
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade --fix-missing && \
    apt-get install -y python3-pip python3-dev 

RUN apt-get install -y portaudio19-dev

RUN apt-get install -y locales git vim

RUN locale-gen en_US.UTF-8

# requirements
COPY requirements.txt requirements.txt
RUN python3 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
COPY . .

# Jupyter lab
RUN python3 -m pip install jupyterlab -i https://pypi.tuna.tsinghua.edu.cn/simple

# pip source
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 config set install.trusted-host https://pypi.tuna.tsinghua.edu.cn

# TORCH
RUN pip3 install torch-1.12.1+cu113-cp38-cp38-linux_x86_64.whl torchaudio-0.12.1+cu113-cp38-cp38-linux_x86_64.whl torchvision-0.13.1+cu113-cp38-cp38-linux_x86_64.whl

# Pytorch3D
RUN tar -xzvf pytorch3d.tgz
RUN pip3 install -e pytorch3d

# Tensorflow 2.9.1
RUN pip3 install tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

# rm 
RUN rm -rf torch-1.12.1+cu113-cp38-cp38-linux_x86_64.whl torchvision-0.13.1+cu113-cp38-cp38-linux_x86_64.whl pytorch3d.tgz  tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl  torchaudio-0.12.1+cu113-cp38-cp38-linux_x86_64.whl

# # zsh
RUN apt-get install -y zsh && apt-get install -y curl
RUN PATH="$PATH:/usr/bin/zsh"
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# # alias
RUN echo 'alias python="python3"' >> ~/.bashrc
RUN echo 'alias python="python3"' >> ~/.zshrc
RUN echo 'alias pip="pip3"' >> ~/.bashrc
RUN echo 'alias pip="pip3"' >> ~/.zshrc
RUN echo "export http_proxy=http://127.0.0.1:7890" >> ~/.zshrc
RUN echo "export https_proxy=http://127.0.0.1:7890" >> ~/.zshrc


# Only display 3 last folder in the path
RUN echo 'PROMPT_DIRTRIM=3' >> ~/.bashrc
RUN echo 'PROMPT_DIRTRIM=3' >> ~/.zshrc

WORKDIR /workspace
#COPY script.sh .
#RUN chmod +x script.sh
#RUN ./script.sh

# OPENSSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:99521' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# # SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# # need?
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
# Export port ssh
EXPOSE 22

# run
CMD /bin/bash -c 'jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password=""'
