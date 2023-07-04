# Extending image
FROM node:16.20.0-alpine3.18
LABEL authors="team 9"

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Versions
RUN npm -v
RUN node -v

COPY /Musify/ /usr/src/app
COPY /Musify/package.json /usr/src/app
COPY /Musify/package-lock.json /usr/src/app

RUN npm install

# Bundle app source
COPY . /usr/src/app

# Environment variables
ENV NODE_ENV test

# Main command
CMD [ "npm", "test" ]