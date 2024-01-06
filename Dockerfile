FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

RUN apt-key del 7fa2af80 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub

ARG DEBIAN_FRONTEND=noninteractive

# Update package sources and install required packages
RUN sed -i 's@/archive.ubuntu.com/@/mirrors.aliyun.com/@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        locales git vim nano python3-pip python3-dev zsh curl openssh-server ffmpeg portaudio19-dev && \
    rm -rf /var/lib/apt/lists/*

# Set locale to UTF-8
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8

# Upgrade pip and install Python packages
COPY requirements.txt requirements.txt
RUN python3 -m pip install --no-cache-dir --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# Set pip source
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip3 config set install.trusted-host https://pypi.tuna.tsinghua.edu.cn

# Install Torch and related packages
COPY torch-1.12.1+cu113-cp38-cp38-linux_x86_64.whl .
COPY torchaudio-0.12.1+cu113-cp38-cp38-linux_x86_64.whl .
COPY torchvision-0.13.1+cu113-cp38-cp38-linux_x86_64.whl .
RUN pip3 install --no-cache-dir torch-1.12.1+cu113-cp38-cp38-linux_x86_64.whl \
    torchaudio-0.12.1+cu113-cp38-cp38-linux_x86_64.whl \
    torchvision-0.13.1+cu113-cp38-cp38-linux_x86_64.whl && \
    rm torch-1.12.1+cu113-cp38-cp38-linux_x86_64.whl \
    torchaudio-0.12.1+cu113-cp38-cp38-linux_x86_64.whl \
    torchvision-0.13.1+cu113-cp38-cp38-linux_x86_64.whl

# Install PyTorch3D
COPY pytorch3d.tgz .
RUN tar -xzvf pytorch3d.tgz && \
    pip3 install --no-cache-dir -e pytorch3d && \
    rm -r pytorch3d.tgz pytorch3d

# Install TensorFlow 2.9.1
COPY tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl .
RUN pip3 install --no-cache-dir tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl && \
    rm tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

# Configure zsh and aliases
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
    echo 'alias python="python3"' >> ~/.bashrc && \
    echo 'alias python="python3"' >> ~/.zshrc && \
    echo 'alias pip="pip3"' >> ~/.bashrc && \
    echo 'alias pip="pip3"' >> ~/.zshrc && \
    echo 'PROMPT_DIRTRIM=3' >> ~/.bashrc && \
    echo 'PROMPT_DIRTRIM=3' >> ~/.zshrc

# Configure SSH
RUN mkdir /var/run/sshd && \
    echo 'root:99521' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

# Set working directory
WORKDIR /workspace

# Start Jupyter Lab
CMD /bin/bash -c 'jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password=""'

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
