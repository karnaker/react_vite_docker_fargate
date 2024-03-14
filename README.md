# React Vite Docker Project

## Introduction

This project is a React application created using Vite. The setup includes Docker configuration for containerization, ensuring consistency across development and deployment environments. Additionally, it leverages Docker Compose for managing multi-container Docker applications.

## Getting Started

These instructions will cover setup, building, and running the project locally and in a Docker container, as well as using Docker Compose for a simplified orchestration process.

## Directory Structure

This section outlines the directory and file structure of the React Vite Docker Project. Understanding this structure is helpful for navigating and modifying the project effectively.

```plaintext
do_react_vite/
├── Dockerfile # Docker configuration for building the image
├── README.md # Project documentation
├── dist
│   ├── assets # Static assets generated by Vite
│   ├── index.html # Generated main HTML file for the app
│   └── vite.svg # Example generated SVG asset
├── docker-compose.yaml # Docker Compose configuration for orchestrating containers
├── env_vars.conf # Environment variables configuration (not tracked by Git)
├── index.html # Entry point HTML file for the Vite application
├── infrastructure
│   ├── main.tf # OpenTofu (or Terraform) infrastructure as code configuration
│   └── dev.tfvars # OpenTofu (or Terraform) variables file for development environment (not tracked by Git)
├── package-lock.json # NPM lock file ensuring consistent installs across machines
├── package.json # NPM package configuration, including scripts and dependencies
├── public
│   └── vite.svg # Public SVG asset, processed by Vite
├── scripts
│   ├── run_tofu_with_1pass.sh # Script to run OpenTofu commands with 1Password integration
│   └── set_env_vars.sh # Script to set environment variables from env_vars.conf
├── src
│   ├── App.jsx # Main React application component
│   ├── components # Reusable React components
│   ├── css # CSS files for styling the application
│   ├── img # Image assets used within the application
│   └── main.jsx # Entry point for the React application
└── vite.config.js # Configuration file for Vite
```

### Prerequisites

- Node.js (version 20.x or higher)
- Docker and Docker Compose (latest versions)
- AWS CLI installed
- 1Password CLI installed for secure retrieval of secrets

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

1. Stop the development server:
   `q` + `enter`

## Docker Setup

1. Build the Docker Image: 
   `docker build -t do_react_vite .`
   This uses the `.dockerignore` and `Dockerfile` in the root of your project to build a Docker image.

1. Run the Docker Container: 
   `docker run -p 3000:3000 --name app_c do_react_vite`
   This command runs your Docker container, mapping the container's port to the port exposed in the Dockerfile.

1. Visit http://localhost:3000 to view your application running in the Docker container.

1. Stop the Docker Container:
   `docker stop app_c`

1. Remove the Docker Container:
   `docker rm app_c`

1. Remove the Docker Image:
   `docker rmi do_react_vite`

## Docker Compose Setup

1. Start the Application with Docker Compose:
   `docker-compose up`
   This command starts your application.

2. Accessing the Application:
   Visit http://localhost:3000 to access your application running through Docker Compose.

3. Shutting Down:
   `docker-compose down --rmi all -v`
   This command stops and removes the containers, networks, volumes, and images created by `docker-compose up`.

## Environment Configuration

Before running OpenTofu, you need to configure environment variables securely:

Download the `env_vars.conf` file from 1Password and place it in the root of your project directory. Make sure this file is listed in your .gitignore to avoid exposing sensitive information.

Run the script to set environment variables:
```bash
source ./scripts/set_env_vars.sh
```
This will automatically configure the necessary environment variables for the project.

## Infrastructure Setup with OpenTofu

Before applying your infrastructure with OpenTofu, ensure you have the necessary configuration for your environment:

Download the `ec2_dev.tfvars` and `ecs_fargate_dev.tfvars` files from 1Password and place each file in the appropriate `./infrastructure` subfolder within your project directory. The tfvars files contain environment-specific variables that are essential for your infrastructure setup.

To initialize and apply your infrastructure with OpenTofu, follow these steps, making sure to include the `-var-file="*.tfvars"` option to specify the use of your variables file, for example:

```bash
./scripts/run_tofu_with_1pass.sh ec2 tofu plan -var-file="ec2_dev.tfvars"
```
```bash
./scripts/run_tofu_with_1pass.sh ec2 tofu apply -var-file="ec2_dev.tfvars"
```
```bash
./scripts/run_tofu_with_1pass.sh ec2 tofu destroy -var-file="ec2_dev.tfvars"
```
## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
