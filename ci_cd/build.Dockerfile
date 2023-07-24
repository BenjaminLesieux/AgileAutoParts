# Use the official Node.js LTS image as the base image
FROM node:lts

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Versions
RUN npm -v
RUN node -v

# Install app dependencies
COPY /Musify/package*.json /usr/src/app/

RUN npm install

# Bundle app source
COPY /Musify/* /usr/src/app

# Expose the port that the Express app listens on
EXPOSE 3000

# Start the Express app
CMD ["node", "index.js"]
