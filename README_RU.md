# Cursor Account Manager

Веб-сервис для управления аккаунтами Cursor с автоматической регистрацией.

## Установка

### 1. Установите Docker и Docker Compose

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезагрузка
sudo reboot
```

### 2. Склонируйте репозиторий

```bash
git clone https://github.com/YOUR_USERNAME/cursor-auto-account.git
cd cursor-auto-account
```

### 3. Настройте переменные (опционально)

```bash
cp .env.example .env
nano .env
```

Измените пароли:
```env
SECRET_KEY=your_secret_key
ADMIN_PASSWORD=your_admin_password
EMAIL_DOMAIN=yourdomain.com
```

### 4. Запустите приложение

```bash
docker-compose up -d
```

### 5. Откройте в браузере

```
http://YOUR_SERVER_IP:8001
```

**Логин:** admin  
**Пароль:** admin (или тот, что указали в .env)

## Управление

```bash
# Статус
docker-compose ps

# Логи
docker-compose logs -f

# Остановка
docker-compose down

# Перезапуск
docker-compose restart
```

## Готово!

Все устанавливается автоматически. Никаких дополнительных настроек не требуется.