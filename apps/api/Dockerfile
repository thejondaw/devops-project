FROM node:14-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --verbose
COPY . .
ENV PORT=3000 \
    DBUSER='user' \
    DB='toptal' \
    DBPASS='password' \
    DBHOST='IP' \
    DBPORT=5432
EXPOSE 3000
USER node
CMD [ "npm", "start" ]