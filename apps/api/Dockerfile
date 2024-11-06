FROM node:14-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --verbose
COPY . .
ENV PORT=3000 \
    DBUSER='' \
    DB='' \
    DBPASS='' \
    DBHOST='' \
    DBPORT=5432
EXPOSE 3000
USER node
CMD [ "npm", "start" ]