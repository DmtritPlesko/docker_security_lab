echo "🐳 Настройка лабораторной работы по Docker безопасности..."

# Проверка и установка Docker
if ! command -v docker &> /dev/null; then
    echo "Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Создание рабочей директории
mkdir -p docker-security-lab
cd docker-security-lab

# Создание уязвимого Dockerfile
cat > Dockerfile << 'EOF'
    FROM ubuntu:20.04

    RUN apt-get update && apt-get install -y \
        nginx \
        curl \
        sudo \
        net-tools \
        && rm -rf /var/lib/apt/lists/*

    RUN useradd -m -s /bin/bash appuser && echo 'appuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

    COPY secret-app /home/appuser/
    COPY flag.txt /root/flag.txt

    EXPOSE 80

    CMD ["/home/appuser/secret-app"]
EOF

# Создание тестовых файлов
echo "#!/bin/bash" > secret-app
echo "echo 'App is running...'" >> secret-app  
echo "sleep infinity" >> secret-app
chmod +x secret-app

echo "flag{container_escape_success}" > flag.txt

# Сборка уязвимого образа
docker build -t vulnerable-app:latest .

# Скачивание Docker Bench Security
git clone https://github.com/docker/docker-bench-security.git

echo "Проверка установки..."
docker images | grep vulnerable-app && echo "✅ Образ собран" || echo "❌ Ошибка сборки"
[ -f "flag.txt" ] && echo "✅ Файлы созданы" || echo "❌ Ошибка создания файлов"
echo "🎉 Установка завершена! Перейдите к task1.md"