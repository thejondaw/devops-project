FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --verbose
COPY . .

ENV PORT=3000
ENV DBUSER='user'
ENV DB='toptal'
ENV DBPASS='password'
ENV DBHOST='IP'
ENV DBPORT=5432

CMD [ "npm", "start" ]