# 9 Контейнеризация

Docker Engine 29.9.3 и Docker Compose v5.7.1. Учётная запись devops входит в группы sudo и docker. Версии подтверждены исходными скриншотами отчёта; происхождение пакета из официального репозитория следует отдельно проверить через apt-cache policy docker-ce.

Проект размещён в /home/devops/app. Доставка из корня репозитория: rsync -avz --delete --exclude=.env app/ devops:app/ (сначала с --dry-run).

Секретный файл /home/devops/app/.env создаётся только на сервере, chmod 600. Пароль формируется openssl rand -hex 16. В репозитории хранится .env.example; .env исключён через .gitignore и .dockerignore.

Запуск: cd ~/app && docker compose up -d --build --wait. Сервисы app и db используют сеть app_backend, адрес базы DB_HOST=db. СУБД postgres:16-alpine проходит pg_isready перед запуском приложения. Именованный том app_db_data смонтирован в /var/lib/postgresql/data. down сохраняет данные; down -v удаляет том. Перед учебным сбросом сохранён /home/devops/pr7-before-reset.sql.

Публикуется только 127.0.0.1:5000:5000. PostgreSQL 5432 не публикуется. В HTTPS-блок /etc/nginx/sites-available/devops-site добавлен location /app/ с proxy_pass http://127.0.0.1:5000/ и заголовками Host, X-Real-IP, X-Forwarded-For, X-Forwarded-Proto. Статический location / сохранён. После изменения: sudo nginx -t && sudo systemctl reload nginx.

Проверки: docker compose ps; docker compose exec app id; ss -tln; stat -c %a ~/app/.env; curl --cacert ~/devops.crt https://devops.local/app/health. Аудит раздела контейнеризации: bash ~/audit.sh. При штатной публикации код 0, при 5000:5000 код 1. Исходный аудит ПР5–6 в предоставленном проекте отсутствует; данный файл реализует раздел 5.

Создан снимок VirtualBox 05-docker-compose, UUID d640acfd-5671-415c-a0e5-cbf6463fc5b4.
