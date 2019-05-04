FROM node:10

# Create app directory
WORKDIR /usr/src/app

# The image comes with Node.js and NPM already installed s
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

# Our app binds to port 8080 so we will use the EXPOSE instruction to have it mapped by the docker daemon:
EXPOSE 8080

# Define the command to run your app using CMD 
CMD [ "npm", "start" ] # npm start -> node server.js

