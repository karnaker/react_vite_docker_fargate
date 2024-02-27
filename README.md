# React Vite Docker Project

## Introduction

This project is a React application created using Vite. The setup includes Docker configuration for containerization, ensuring consistency across development and deployment environments. Additionally, it leverages Docker Compose for managing multi-container Docker applications.

## Getting Started

These instructions will cover setup, building, and running the project locally and in a Docker container, as well as using Docker Compose for a simplified orchestration process.

### Prerequisites

- Node.js (version 20.x or higher)
- Docker and Docker Compose (latest versions)

## Local Development Setup

1. Clone the repository:
   `git clone https://yourprojecturl.git your-project-directory`

2. Navigate to the project directory:
   `cd your-project-directory`

3. Install dependencies:
   `npm install`

4. Start the development server:
   `npm run dev`

5. Visit http://localhost:5173 to view your application.

## Docker Setup

1. Build the Docker Image: 
   `docker build -t do_react_vite .`
   This uses the `.dockerignore` and `Dockerfile` in the root of your project to build a Docker image.

2. Run the Docker Container: 
   `docker run -p 3000:3000 do_react_vite`
   This command runs your Docker container, mapping the container's port to the port exposed in the Dockerfile.

3. Visit http://localhost:3000 to view your application running in the Docker container.

## Docker Compose Setup

1. Start the Application with Docker Compose:
   `docker-compose up`
   This command starts your application.

2. Accessing the Application:
   Visit http://localhost:3000 to access your application running through Docker Compose.

3. Shutting Down:
   `docker-compose down --rmi all -v`
   This command stops and removes the containers, networks, volumes, and images created by `docker-compose up`.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
