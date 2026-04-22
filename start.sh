#!/bin/sh

# 1. 启动虚拟显示器
Xvfb :99 -screen 0 1280x900x24 &
export DISPLAY=:99
sleep 2

# 2. 启动 VNC 和 noVNC
x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
websockify --web=/usr/share/novnc 6080 localhost:5900 &
sleep 2

# 3. 先启动 Python 程序（让它占领 8081 端口）
# 我们把它放到后台，并记录日志
PORT=8081 python main.py > /tmp/python_app.log 2>&1 &

# 4. 等待几秒，确保 Python 端口已经监听
sleep 5

# 5. 最后启动 Nginx（前台运行，作为容器的主进程）
nginx -g "daemon off;"
