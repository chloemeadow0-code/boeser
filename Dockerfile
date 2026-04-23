FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    fonts-liberation \
    fonts-noto-cjk \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    nginx \
    curl \
    git \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @jackwener/opencli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# 直接去源头把完整的包裹拿回来，挑出我们需要的那副眼镜，然后把剩下的清理干净
RUN git clone --depth 1 https://github.com/jackwener/opencli.git /tmp/opencli-repo && \
    EXT_DIR=$(dirname $(find /tmp/opencli-repo -name "manifest.json" | head -n 1)) && \
    cp -r $EXT_DIR /app/opencli-extension && \
    rm -rf /tmp/opencli-repo

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN playwright install chromium

COPY main.py .
# 将原本覆盖到 sites-enabled 的完整配置，直接替换掉系统的 nginx 主配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh .
# 强制转换换行符为 LF，创建 uid 1000 的普通用户，并给依赖目录赋权
RUN sed -i 's/\r$//' start.sh && \
    useradd -m -u 1000 user && \
    mkdir -p /data /var/lib/nginx /var/log/nginx && \
    chown -R 1000:1000 /app /data /var/lib/nginx /var/log/nginx /etc/nginx && \
    chmod +x start.sh

# 切换到普通用户运行服务
VOLUME ["/data"]
EXPOSE 8080
CMD ["./start.sh"]