FROM node:14-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production
COPY src ./src

FROM node:14-alpine
RUN apk add --no-cache tini
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app ./
USER node
ENV PORT=3000
ENV DBUSER='user'
ENV DB='toptal'
ENV DBPASS='password'
ENV DBHOST='IP'
ENV DBPORT=5432
EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "src/index.js"]