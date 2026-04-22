#!/bin/sh

# 1. 启动虚拟显示器和 VNC 
Xvfb :99 -screen 0 1280x900x24 &
export DISPLAY=:99
sleep 2
x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
websockify --web=/usr/share/novnc 6080 localhost:5900 &
sleep 2

# 2. 启动 Python 服务
# 这里我们显式指定 8081 端口，方便 Nginx 转发
PORT=8081 python main.py &
sleep 5

# 3. 前台启动 Nginx（这是容器存活的关键）
# -p /tmp 确保 pid 文件写在有权限的地方
nginx -g "daemon off; pid /tmp/nginx.pid;"
