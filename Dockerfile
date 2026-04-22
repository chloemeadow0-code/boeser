# 直接使用微软官方打包好的完美环境
FROM mcr.microsoft.com/playwright/python:v1.43.0-jammy

WORKDIR /app

# 安装你的 Python 库
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制代码
COPY . .

# 直接启动你的 MCP 服务！
CMD ["python", "-u", "main.py"]