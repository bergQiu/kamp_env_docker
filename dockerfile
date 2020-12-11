# Desc: create kamp env image
# Date: 20201127 
# User: berg
# Version: kamp_env2

FROM ubuntu:16.04

ARG PIP_SRC=https://mirrors.aliyun.com/pypi/simple/

# 系统级需要的工具
ARG TOOLS="vim wget python3.5 python3.5-dev python-qt4 libglib2.0-dev gcc git expect ssh"

# 设置系统环境语言为中文
ENV LANG=C.UTF-8\
    PYTHONIOENCODING=utf-8

# 修改系统时区,安装系统工具
COPY ["id_rsa", "sources.list", "Shanghai", "get-pip.py", "/tmp/"]
RUN rm /etc/localtime \
    && cp /tmp/Shanghai /etc/localtime \ 
    && cp /tmp/sources.list /etc/apt/ \
    && apt-get clean -y --fix-missing --no-install-recommends \
    && apt-get update -y --fix-missing --no-install-recommends \
    && apt-get upgrade -y --fix-missing --no-install-recommends \
    && for i in ${TOOLS};do apt-get install -y --fix-missing --no-install-recommends $i;done \
    && ln -s /usr/bin/python3.5 /usr/bin/python3 

# python 相关环境
COPY ["requirements.txt", "/tmp/"]
RUN python3 /tmp/get-pip.py -i ${PIP_SRC} \
    && pip3 install -r /tmp/requirements.txt -i ${PIP_SRC}

# 安装nodejs运行环境&依赖
COPY ["package.json", "/tmp/"]
ARG NPM_SRC=https://registry.npm.taobao.org
RUN apt-get install -y --fix-missing --no-install-recommends npm \
    && npm config set registry ${NPM_SRC} \
    && npm install npm@6.10.1 -g \
    && npm install n -g \
    && n 10.15.2 \
    && npm install webpack@3.6.0 -g \
    && mkdir /home/package && cd /home/package && cp /tmp/package.json . \
    && npm install

# 可变参数的传递
ARG branch=test

# 配置kamp文件项目
COPY ["projectInit.sh", "uwsgi.ini", "config.yaml", "/tmp/"]
RUN echo '/*---------- 正在创建项目文件----------*/' \
    && cd /root && mkdir .ssh && cp /tmp/id_rsa /root/.ssh/ \
    && cd /home && cp /tmp/projectInit.sh . && chmod +x projectInit.sh && ./projectInit.sh \
    && git clone -b ${branch} --single-branch --progress ssh://git@www.marcia7.top:9021/zhijiang/kamp.git \
    && rm /root/.ssh/id_rsa \
    && cp /tmp/config.yaml kamp/kamp/ \
    && cd /home/kamp && ln -s /home/package/node_modules/ /home/kamp/node_modules \
    && npm link webpack \
    && webpack && mkdir logs \
    && mkdir /etc/uwsgi \
    && cp /tmp/uwsgi.ini /etc/uwsgi  

ENTRYPOINT uwsgi --ini /etc/uwsgi/uwsgi.ini && /bin/bash