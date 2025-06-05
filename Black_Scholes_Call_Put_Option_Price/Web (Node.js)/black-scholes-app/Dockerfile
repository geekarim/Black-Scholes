FROM node:24-alpine

COPY package.json /app/
COPY index.js /app/
COPY index.html /app/

WORKDIR /app

RUN npm install

CMD ["node", "index.js"]