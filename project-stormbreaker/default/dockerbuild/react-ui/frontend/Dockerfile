FROM  node:14.15.4-alpine3.12

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./
COPY src ./src
COPY public ./public

# Install app dependencies
RUN npm install

# Build the app
RUN npm run build

# Copy the rest of the app source code to the working directory
COPY . .

RUN npm install -g serve

# Expose the port on which the app will run
EXPOSE 3000

# Start the app
CMD [ "serve", "-s" , "build"]
