FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --verbose
COPY . .

ENV PORT=4000
ENV API_HOST=

CMD [ "npm", "start" ]
