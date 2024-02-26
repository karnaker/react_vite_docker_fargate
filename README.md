# React Vite Docker Project

## Introduction

This project is a React application created using Vite. The setup includes Docker configuration for containerization, ensuring consistency across development and deployment environments.

## Getting Started

These instructions will cover setup, building, and running the project locally and in a Docker container.

### Prerequisites

- Node.js (version 20.x or higher)
- Docker (latest version)

## Local Development Setup

1. Clone the repository:
`git clone https://yourprojecturl.git your-project-directory`

1. Navigate to the project directory:
`cd your-project-directory`

1. Install dependencies:
`npm install`

1. Start the development server:
`npm run dev`

1. Visit http://localhost:5173 to view your application.

## Docker Setup

1. Build the Docker Image: 
`docker build -t do_react_vite .`
This uses the `.dockerignore` and `Dockerfile` in the root of your project.

1. Run the Docker Container: 
`docker run -p 3000:3000 do_react_vite`
Run your Docker container mapping the port to the one exposed in the Dockerfile.

1. Visit http://localhost:3000 to view your application running in the Docker container.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
