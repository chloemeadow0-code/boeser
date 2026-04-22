#!/bin/sh

# 自动修复换行符（双重保险）
sed -i 's/\r$//' start.sh

# 1. 启动虚拟显示器
Xvfb :99 -screen 0 1280x900x24 &
export DISPLAY=:99
sleep 2

# 2. 启动 VNC 服务 (noVNC 后台运行)
x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
websockify --web=/usr/share/novnc 6080 localhost:5900 &
sleep 2

# 3. 启动 Python MCP 服务 (后台运行)
PORT=8081 python main.py &
sleep 5

# 4. 启动 Nginx (前台运行，作为主进程)
# 如果 Nginx 挂了，容器会立即报错并重启，方便我们看日志
nginx -g "daemon off;"
