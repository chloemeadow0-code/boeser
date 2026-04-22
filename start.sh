#!/bin/sh

# 启动虚拟显示器
Xvfb :99 -screen 0 1280x900x24 &
export DISPLAY=:99
sleep 3

# 启动 VNC 服务
x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
sleep 2

# 启动 noVNC
websockify --web=/usr/share/novnc 6080 localhost:5900 &
sleep 1

# 启动 nginx，并强制把报错日志打到控制台，方便排错
nginx -g "error_log /dev/stderr info;" &

# 启动 MCP 服务，明确将后端的 Uvicorn 隔离在 8082 端口避免无限循环
PORT=8082 python main.py