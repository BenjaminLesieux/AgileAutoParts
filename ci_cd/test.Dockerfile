# Extending image
FROM node:latest
LABEL authors="team 9"

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Versions
RUN npm -v
RUN node -v
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

COPY /with-jest-app/package.json /usr/src/app
COPY /with-jest-app/pnpm-lock.yaml /usr/src/app/

RUN pnpm install --frozen-lockfile

COPY /with-jest-app/ /usr/src/app

# Environment variables
ENV NODE_ENV test

# Main command
CMD [ "npm", "test" ]