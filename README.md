# gallery_env
embed core ai env into docker container.

many thanks to this [bro](https://dinhanhthi.com/workflow-building-docker-environment-for-data-science-tensorflow-torch-gpu)

## the folder structure

```shell
.
├── Dockerfile
├── pytorch3d.tgz
├── README.md
├── requirements.txt
├── tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
├── torch-1.12.1+cu113-cp38-cp38-linux_x86_64.whl
├── torchaudio-0.12.1+cu113-cp38-cp38-linux_x86_64.whl
└── torchvision-0.13.1+cu113-cp38-cp38-linux_x86_64.whl
```

because of the connection slowest in china mainland, these files can be downloaded through a proxy

- [pytorch3d](https://github.com/facebookresearch/pytorch3d.git)
- [tensorflow](https://pypi.tuna.tsinghua.edu.cn/packages/b0/30/bd03cd1ab1f0b295f37ed96dcee5942f81d4486648adb8079215f5c4f367/tensorflow-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl)
- [torch](https://download.pytorch.org/whl/cu113/torch-1.12.1%2Bcu113-cp38-cp38-linux_x86_64.whl)
- [torchaudio](https://download.pytorch.org/whl/cu113/torchaudio-0.12.1%2Bcu113-cp38-cp38-linux_x86_64.whl)
- [torchvision](https://download.pytorch.org/whl/cu113/torchvision-0.13.1%2Bcu113-cp38-cp38-linux_x86_64.whl)

## build image

```shell
sudo docker build -t aigallery . -f Dockerfile
```

## run container

```shell
sudo docker run --name aigo --gpus all \
  -v /home/aikedaer/workspace:/workspace/ \ # Change to your local directory
  -dp 8888:8888 \
  -dp 6789:22 \
  -it aigallery
```
## enter the container

```shell
sudo docker exec -it aigo zsh # Yes, we use zsh!!!
```

## verify GPU support

Make sure the GPU driver is successfully installed on your machine and read this note to allow Docker Engine communicate with this physical GPU.

```shell
# GPU driver
nvidia-smi

# CUDA version
nvcc --version

# cuDNN version
cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2

# TensorFlow works with CPU?
python3 -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"

# TensorFlow works with GPU?
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

# Torch works with GPU?
python3 -c "import torch; print(torch.cuda.is_available())"
```

## use SSH to access the container

```shell
# First run the ssh server in the container first
sudo docker exec -d aigo /usr/sbin/sshd

# Access it via
ssh -p 6789 root@localhost
# password of root: 99521
```

## Go to http://localhost:8888 to open the Jupyter Notebook

