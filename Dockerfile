# 直接使用微软官方打包好的完美环境
FROM mcr.microsoft.com/playwright/python:v1.43.0-jammy

WORKDIR /app

# 安装你的 Python 库
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制代码
COPY . .

# 赋予启动脚本执行权限，防止没有权限运行
RUN chmod +x start.sh

# 执行统一启动脚本 (包含虚拟显示器、VNC、Nginx和MCP)
CMD ["./start.sh"]