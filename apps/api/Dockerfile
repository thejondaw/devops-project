# Этап сборки
FROM node:20-alpine AS builder
WORKDIR /usr/src/app

# Копируем файлы package.json и package-lock.json (если есть)
COPY package*.json ./

# Устанавливаем зависимости с помощью npm install
RUN npm install --verbose

# Копируем исходный код
COPY src ./src

# Проверяем на уязвимости
RUN npm audit

# Этап выполнения
FROM node:20-alpine

# Устанавливаем dumb-init
RUN apk add --no-cache dumb-init

WORKDIR /usr/src/app

# Копируем собранные файлы и зависимости
COPY --from=builder /usr/src/app ./

# Используем непривилегированного пользователя
USER node

# Объявляем переменные окружения
ENV PORT=3000 \
    DBUSER='user' \
    DB='toptal' \
    DBPASS='password' \
    DBHOST='IP' \
    DBPORT=5432

# Открываем порт
EXPOSE 3000

# Используем dumb-init как ENTRYPOINT
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Запускаем приложение
CMD ["node", "src/index.js"]