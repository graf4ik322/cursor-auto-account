# 🚀 Быстрый старт - Cursor Account Manager

Полная установка и настройка за 5 минут!

## 📋 Требования

- Linux сервер (Ubuntu 18.04+, CentOS 7+)
- Docker и Docker Compose
- Git

## 🔧 Установка

### Шаг 1: Установка Docker и Docker Compose

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезагрузка для применения изменений группы
sudo reboot
```

### Шаг 2: Клонирование репозитория

```bash
# Клонирование репозитория
cd ~
git clone https://github.com/YOUR_USERNAME/cursor-auto-account.git
cd cursor-auto-account

# Копирование конфигурации
cp .env.example .env
```

### Шаг 3: Настройка (опционально)

**Важно:** Все устанавливается автоматически! Этот шаг только для изменения настроек по умолчанию.

```bash
# Редактирование конфигурации
nano .env
```

Настройте следующие переменные:
```env
# Настройки безопасности (обязательно измените!)
SECRET_KEY=your_generated_secret_key
ADMIN_PASSWORD=your_admin_password

# Настройки email
EMAIL_DOMAIN=yourdomain.com
```

### Шаг 4: Генерация секретного ключа

```bash
# Генерация секретного ключа
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Скопируйте результат в переменную `SECRET_KEY` в файле `.env`.

### Шаг 5: Запуск приложения

```bash
# Запуск контейнеров
docker-compose up -d

# Проверка статуса
docker-compose ps
```

**Что происходит при запуске:**
- ✅ Автоматически устанавливается MySQL 8.0
- ✅ Создается база данных `cursor_accounts`
- ✅ Запускается приложение Cursor Account Manager
- ✅ Создается администратор по умолчанию
- ✅ Настраивается сеть между контейнерами

### Шаг 6: Проверка работы

Откройте браузер и перейдите по адресу:
```
http://YOUR_SERVER_IP:8001
```

**Просмотр логов:**
```bash
docker-compose logs -f
```

## 🎉 Готово!

Ваше приложение запущено и готово к использованию!

**Логин по умолчанию:**
- Пользователь: `admin`
- Пароль: `admin` (или тот, что вы указали в `.env`)

## 🔧 Управление

### Просмотр статуса
```bash
docker-compose ps
```

### Просмотр логов
```bash
docker-compose logs -f
```

### Остановка
```bash
docker-compose down
```

### Перезапуск
```bash
docker-compose restart
```

### Обновление
```bash
git pull
docker-compose down
docker-compose up -d --build
```

## 🆘 Устранение неполадок

### Проблема: Приложение не запускается
```bash
# Проверка логов
docker-compose logs app

# Проверка статуса контейнеров
docker-compose ps
```

### Проблема: Не могу подключиться к приложению
1. Проверьте, что порт 8001 открыт в файрволе
2. Убедитесь, что контейнеры запущены: `docker-compose ps`
3. Проверьте логи: `docker-compose logs app`

### Проблема: База данных не подключается
```bash
# Проверка логов базы данных
docker-compose logs db

# Перезапуск контейнеров
docker-compose down
docker-compose up -d
```

## 📝 Чек-лист установки

- [ ] Docker установлен
- [ ] Docker Compose установлен
- [ ] Репозиторий склонирован
- [ ] Файл `.env` создан
- [ ] Секретный ключ сгенерирован
- [ ] Контейнеры запущены
- [ ] Приложение доступно по адресу `http://YOUR_SERVER_IP:8001`

## 🔗 Полезные ссылки

- [Подробное руководство по развертыванию](DEPLOYMENT_GUIDE_RU.md)
- [FAQ](FAQ_RU.md)
- [Руководство по безопасности](SECURITY_RU.md)