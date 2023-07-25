# Extending image
FROM node:latest
LABEL authors="team 9"

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Versions
RUN npm -v
RUN node -v

RUN npm install -g pnpm

# Install app dependencies
COPY /with-jest-app/package.json /usr/src/app/
COPY /with-jest-app/pnpm-lock.yaml /usr/src/app/

RUN pnpm install --frozen-lockfile

# Bundle app source
COPY /with-jest-app/ /usr/src/app/

# Port to listener
EXPOSE 3000

# Environment variables
ENV NODE_ENV production
ENV PORT 3000
ENV PUBLIC_PATH "/"

CMD ["npm", "run", "lint"]