#!/usr/bin/env bash
set -euo pipefail

echo "Обновление пакетов..."
sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get upgrade -y

echo "Установка nginx и curl..."
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl

echo "Создание страницы..."
VM_HOSTNAME=$(hostname)
PUBLIC_IP=$(curl -4 --fail --silent --show-error --max-time 20 https://ifconfig.me/ip)
SETUP_DATE=$(date -u '+%d.%m.%Y %H:%M:%S UTC')

cat <<EOF | sudo tee /var/www/html/index.html > /dev/null
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Создание виртуальной машины — Лабораторная №1</title>
  <style>
    * { box-sizing: border-box; }
    body { margin: 0; padding: 48px 20px; background: #f2f5fa; color: #17243c;
      font: 18px/1.6 system-ui, -apple-system, sans-serif; }
    main { max-width: 860px; margin: 0 auto; padding: 48px;
      background: white; border: 1px solid #dce3ee; border-radius: 20px; }
    .label { margin: 0; color: #3159a6; font-size: 14px; font-weight: 700;
      text-transform: uppercase; letter-spacing: .08em; }
    h1 { font-size: clamp(30px, 5vw, 46px); line-height: 1.15; margin: 18px 0; }
    .intro { color: #4c5c74; }
    dl { margin: 32px 0; }
    dl div { padding: 16px 0; border-top: 1px solid #e3e8f0; }
    dt { color: #596a82; font-size: 14px; }
    dd { margin: 4px 0 0; font-weight: 600; overflow-wrap: anywhere; }
    footer { font-size: 14px; color: #596a82; }
    @media (max-width: 600px) { body { padding: 20px 12px; } main { padding: 24px; } }
  </style>
</head>
<body>
  <main>
    <p class="label">Yandex Cloud · Лабораторная работа №1</p>
    <h1>Создание виртуальной машины</h1>
    <p class="intro">Собственная HTML-страница на виртуальной машине.
      Веб-сервер nginx установлен и настроен bash-скриптом.</p>
    <dl>
      <div><dt>Имя машины / hostname</dt><dd>$VM_HOSTNAME</dd></div>
      <div><dt>Публичный IPv4</dt><dd>$PUBLIC_IP</dd></div>
      <div><dt>Дата настройки</dt><dd>$SETUP_DATE</dd></div>
    </dl>
    <footer>Ubuntu · nginx · Bash<br>
      Основы облачных технологий на примере Yandex Cloud</footer>
  </main>
</body>
</html>
EOF

sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl is-active --quiet nginx
curl --fail --silent --show-error http://127.0.0.1/ > /dev/null
echo "Готово! Сервер доступен по адресу http://$PUBLIC_IP"
