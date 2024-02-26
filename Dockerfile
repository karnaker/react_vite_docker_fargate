# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /app

# A .dockerignore file should exclude node_modules, dist, and other non-essential files

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install project dependencies using the lock file
RUN npm ci

# Copy the rest of the project files
COPY . .

# Build the app for production
RUN npm run build

# Install `serve` to run the application
RUN npm install -g serve

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Run the app using `serve`
CMD ["serve", "-s", "dist", "-l", "3000"]
