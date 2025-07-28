# Руководство по безопасности

## 🔒 Основные принципы безопасности

### 1. Пароли и аутентификация

#### Создание надежных паролей
- **Минимум 12 символов**
- **Комбинация**: буквы (верхний и нижний регистр), цифры, спецсимволы
- **Избегайте**: простых паролей, личной информации, повторяющихся символов

#### Примеры надежных паролей:
```
✅ Хорошие пароли:
- K9#mP2$vL8@nQ4!
- MyS3cur3P@ssw0rd!
- J8$kL2#mN9@pQ5!

❌ Плохие пароли:
- 123456
- password
- admin
- qwerty
```

#### Генерация секретного ключа
```bash
# Генерация надежного секретного ключа
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 2. Защита файлов конфигурации

#### Файл .env
```bash
# Установка правильных прав доступа
chmod 600 .env

# Проверка прав
ls -la .env
# Должно быть: -rw------- 1 user user
```

#### Содержимое .env файла
```env
# ✅ Правильно - надежные пароли
DB_PASSWORD=MyV3ryS3cur3P@ssw0rd!
ADMIN_PASSWORD=Adm1nS3cur3P@ssw0rd!
SECRET_KEY=your_generated_secret_key_here

# ❌ Неправильно - слабые пароли
DB_PASSWORD=123456
ADMIN_PASSWORD=admin
SECRET_KEY=secret
```

### 3. Настройка базы данных

#### Создание отдельного пользователя
```sql
-- Создание пользователя с ограниченными правами
CREATE USER 'cursor_user'@'localhost' IDENTIFIED BY 'strong_password_123!';
GRANT ALL PRIVILEGES ON *.* TO 'cursor_user'@'localhost';
FLUSH PRIVILEGES;
```

**Примечание:** Приложение автоматически создаст базу данных при первом запуске.

#### Ограничение доступа к MySQL
```ini
# /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
# Привязка только к localhost
bind-address = 127.0.0.1

# Максимальное количество соединений
max_connections = 50

# Таймаут неактивных соединений
wait_timeout = 300
interactive_timeout = 300
```

### 4. Настройка файрвола

#### UFW (Ubuntu/Debian)
```bash
# Установка UFW
sudo apt install ufw

# Настройка правил
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Разрешение SSH (измените порт если нужно)
sudo ufw allow ssh

# Разрешение HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Разрешение порта приложения (только если нужно)
sudo ufw allow 8001

# Включение файрвола
sudo ufw enable

# Проверка статуса
sudo ufw status
```

#### iptables (CentOS/RHEL)
```bash
# Установка firewalld
sudo yum install firewalld

# Запуск и включение
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Настройка зон
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8001/tcp

# Применение изменений
sudo firewall-cmd --reload
```

### 5. Настройка SSH

#### Отключение root логина
```bash
# Редактирование конфигурации SSH
sudo nano /etc/ssh/sshd_config
```

Добавьте или измените:
```ini
# Отключение root логина
PermitRootLogin no

# Использование только SSH ключей (рекомендуется)
PasswordAuthentication no
PubkeyAuthentication yes

# Изменение порта SSH (опционально)
Port 2222

# Ограничение пользователей
AllowUsers your_username
```

#### Создание SSH ключей
```bash
# Генерация SSH ключа
ssh-keygen -t ed25519 -C "your_email@example.com"

# Копирование ключа на сервер
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server_ip

# Тестирование подключения
ssh user@server_ip
```

### 6. Настройка Caddy

#### Безопасные заголовки
```caddyfile
cursor.yourdomain.com {
    # Безопасные HTTP заголовки
    header {
        # Защита от XSS атак
        X-XSS-Protection "1; mode=block"
        
        # Защита от MIME sniffing
        X-Content-Type-Options "nosniff"
        
        # Защита от clickjacking
        X-Frame-Options "DENY"
        
        # Строгая политика реферера
        Referrer-Policy "strict-origin-when-cross-origin"
        
        # HSTS (принудительный HTTPS)
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # Скрытие информации о сервере
        -Server
    }
    
    # Ограничение размера запросов
    request_body {
        max_size 10MB
    }
    
    # Логирование
    log {
        output file /var/log/caddy/access.log
        format json
        level INFO
    }
}
```

### 7. Мониторинг и логирование

#### Настройка логирования
```bash
# Создание директории для логов
sudo mkdir -p /var/log/cursor-app
sudo chown user:user /var/log/cursor-app

# Настройка ротации логов
sudo nano /etc/logrotate.d/cursor-app
```

Содержимое:
```
/var/log/cursor-app/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 user user
}
```

#### Мониторинг подозрительной активности
```bash
# Проверка неудачных попыток входа
sudo grep "Failed password" /var/log/auth.log

# Проверка подозрительных IP
sudo netstat -tulpn | grep :8001

# Мониторинг использования ресурсов
htop
df -h
free -h
```

### 8. Регулярные обновления

#### Автоматические обновления безопасности
```bash
# Ubuntu/Debian
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# CentOS/RHEL
sudo yum install yum-cron
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
```

#### Обновление Docker образов
```bash
# Создание скрипта обновления
nano ~/update.sh
```

Содержимое:
```bash
#!/bin/bash
cd ~/cursor-auto-account
git pull
docker-compose down
docker-compose up -d --build
docker system prune -f
```

```bash
# Сделать исполняемым
chmod +x ~/update.sh

# Добавить в crontab (еженедельно)
crontab -e
0 3 * * 0 /home/user/update.sh
```

### 9. Резервное копирование

#### Автоматические резервные копии
```bash
# Создание скрипта резервного копирования
nano ~/backup.sh
```

Содержимое:
```bash
#!/bin/bash

# Настройки
DB_USER="cursor_user"
DB_NAME="cursor_accounts"
BACKUP_DIR="/home/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Создание директории
mkdir -p $BACKUP_DIR

# Резервная копия базы данных
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/db_$DATE.sql

# Резервная копия конфигурации
cp .env $BACKUP_DIR/env_$DATE.backup

# Сжатие
gzip $BACKUP_DIR/db_$DATE.sql

# Удаление старых резервных копий (старше 30 дней)
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
find $BACKUP_DIR -name "*.backup" -mtime +30 -delete

echo "Резервная копия создана: $BACKUP_DIR/db_$DATE.sql.gz"
```

### 10. Проверка безопасности

#### Регулярные проверки
```bash
# Проверка открытых портов
sudo netstat -tulpn

# Проверка процессов
ps aux | grep -E "(mysql|docker|caddy)"

# Проверка прав доступа
ls -la ~/cursor-auto-account/.env
ls -la /etc/mysql/

# Проверка логов на подозрительную активность
sudo tail -f /var/log/auth.log | grep -i "failed\|invalid\|error"
```

#### Инструменты для проверки безопасности
```bash
# Установка инструментов
sudo apt install lynis rkhunter

# Проверка системы с Lynis
sudo lynis audit system

# Проверка на руткиты
sudo rkhunter --check
```

## 🚨 Чрезвычайные ситуации

### Компрометация системы

1. **Немедленно отключите сервер от сети**
2. **Создайте резервную копию для анализа**
3. **Проверьте логи на предмет взлома**
4. **Обновите все пароли**
5. **Переустановите систему при необходимости**

### Восстановление после атаки

```bash
# Остановка всех сервисов
sudo systemctl stop mysql
docker-compose down

# Проверка целостности файлов
sudo find /home/user/cursor-auto-account -type f -exec md5sum {} \; > checksums.txt

# Восстановление из резервной копии
mysql -u cursor_user -p cursor_accounts < backup.sql

# Перезапуск сервисов
sudo systemctl start mysql
docker-compose up -d
```

## 📋 Чек-лист безопасности

- [ ] Надежные пароли установлены
- [ ] Файрвол настроен и включен
- [ ] SSH защищен (отключен root, используются ключи)
- [ ] База данных ограничена localhost
- [ ] Файл .env защищен (права 600)
- [ ] Автоматические обновления включены
- [ ] Резервные копии настроены
- [ ] Логирование включено
- [ ] SSL сертификат работает
- [ ] Безопасные заголовки HTTP настроены

## 🔗 Дополнительные ресурсы

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [MySQL Security Guidelines](https://dev.mysql.com/doc/refman/8.0/en/security.html)
- [Caddy Security](https://caddyserver.com/docs/security)

---

**Помните:** Безопасность - это непрерывный процесс. Регулярно проверяйте и обновляйте настройки безопасности.