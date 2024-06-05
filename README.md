# React Vite Docker Project

## Introduction

This project is a React application created using Vite. It exposes two endpoints: one is a health check (/health), and the other queries the Open-Meteo API for current weather data (/weather). The setup includes Docker configuration for containerization, ensuring consistency across development and deployment environments. Additionally, it leverages Docker Compose for managing multi-container Docker applications. The project also integrates OpenTofu, an Infrastructure as Code (IaC) tool, to deploy the application to AWS Fargate for Amazon ECS, ensuring scalable and reliable cloud deployment.

## Getting Started

These instructions will cover setup, building, and running the project locally and in a Docker container, as well as using Docker Compose for a simplified orchestration process. Additionally, steps to deploy the application to AWS Fargate using OpenTofu are provided.

## Directory Structure

This section outlines the directory and file structure of the React Vite Docker Project. Understanding this structure is helpful for navigating and modifying the project effectively.

```plaintext
do_react_vite/
├── Dockerfile # Docker configuration for building the image
├── README.md # Project documentation
├── dist/
│   ├── assets/ # Static assets generated by Vite
│   ├── index.html # Generated main HTML file for the app
│   └── vite.svg # Example generated SVG asset
├── docker-compose.yaml # Docker Compose configuration for orchestrating containers
├── env_vars.conf # Environment variables configuration (not tracked by Git)
├── index.html # Entry point HTML file for the Vite application
├── infrastructure/
│   └── ecs_fargate/
│       ├── ecs_fargate_dev.tfvars # Variables file for ECS Fargate environment (not tracked by Git)
│       ├── stage1.tf
│       ├── stage1_files.list
│       ├── stage2.tf
│       ├── stage2_files.list
│       ├── stage2_http_listener.tf
│       ├── stage3.tf
│       ├── stage3_files.list
│       ├── stage4.tf
│       ├── stage4_files.list
│       ├── terraform.tfstate
│       └── terraform.tfstate.backup
├── package-lock.json # NPM lock file ensuring consistent installs across machines
├── package.json # NPM package configuration, including scripts and dependencies
├── public/
│   └── vite.svg # Public SVG asset, processed by Vite
├── scripts/
│   ├── delete_ecr_images.sh # Deletes images from AWS ECR
│   ├── delete_local_docker_images.sh # Removes local Docker images created by deploy script
│   ├── deploy_to_ecr.sh # Deploys Docker image to AWS ECR
│   ├── fetch_aws_credentials.sh # Fetches AWS credentials from 1Password
│   ├── get_aws_account_id.sh # Retrieves the AWS account ID using AWS CLI
│   ├── load_tfvars.sh # Loads variables from Terraform vars files
│   ├── rename_stage_files.sh # Renames stage files based on include/exclude lists
│   ├── run_tofu_in_infrastructure.sh # Runs OpenTofu commands in specified infrastructure directory
│   └── set_env_vars.sh # Script to set environment variables from env_vars.conf
├── src/
│   ├── App.jsx # Main React application component
│   ├── components # Reusable React components
│   │   ├── CurrentWeather.jsx
│   │   ├── HealthCheck.jsx
│   │   └── Welcome.jsx
│   ├── css # CSS files for styling the application
│   │   └── main.css
│   ├── img # Image assets used within the application
│   │   └── sammy.jpeg
│   └── main.jsx # Entry point for the React application
└── vite.config.js # Configuration file for Vite
```

### Prerequisites

- Node.js (version 20.x or higher)
- Docker and Docker Compose (latest versions)
- AWS CLI installed
- 1Password CLI installed for secure retrieval of secrets
- OpenTofu installed

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

## OpenTofu Setup - Environment Configuration

Before running OpenTofu, you need to configure environment variables securely:

Download the `env_vars.conf` file from 1Password and place it in the root of your project directory. Make sure this file is listed in your .gitignore to avoid exposing sensitive information. This file includes necessary environment variables for the project.

## Infrastructure Setup with OpenTofu

Before applying your infrastructure with OpenTofu, ensure you have the necessary configuration for your environment:

Download the `ecs_fargate_dev.tfvars` file from 1Password and place the file in the appropriate `./infrastructure` subfolder within your project directory. The tfvars file contains environment-specific variables that are essential for your infrastructure setup.

To initialize and apply your infrastructure with OpenTofu, follow these steps, making sure to include the `-var-file="*.tfvars"` option to specify the use of your variables file, for example:

```bash
./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu plan -var-file="ecs_fargate_dev.tfvars"
```
```bash
./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu apply -var-file="ecs_fargate_dev.tfvars"
```
```bash
./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu destroy -var-file="ecs_fargate_dev.tfvars"
```

## Deployment to AWS Fargate

1. **Exclude all tf files**:

   ```sh
   ./scripts/rename_stage_files.sh exclude ./infrastructure/ecs_fargate stage2_files.list stage4_files.list
   ```
1. **Include stage 1 files**:

   ```sh
   ./scripts/rename_stage_files.sh include ./infrastructure/ecs_fargate stage1_files.list
   ```

1. **Plan the infrastructure changes**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu plan -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Apply the changes to deploy the infrastructure**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu apply -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Deploy to ECR**: Use the `deploy_to_ecr.sh` script to build your Docker image, tag it, and push it to the AWS ECR repository you just created. This script automates authentication with AWS, building the Docker image, tagging it with the appropriate project name and environment, and pushing it to ECR.

   ```sh
   ./scripts/deploy_to_ecr.sh ./infrastructure/ecs_fargate/ecs_fargate_dev.tfvars
   ```

1. **Include stage 2 files**:

   ```sh
   ./scripts/rename_stage_files.sh include ./infrastructure/ecs_fargate stage2_files.list
   ```

1. **Plan the infrastructure changes**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu plan -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Apply the changes to deploy the infrastructure**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu apply -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Test service**: The output from the last `tofu apply` will display the URL to use to reach the service. Copy and paste that URL into your browser, and you should see the service respond.

1. **Exclude stage 2 files**:

   ```sh
   ./scripts/rename_stage_files.sh exclude ./infrastructure/ecs_fargate stage2_files.list
   ```

1. **Include stage 3 files**:

   ```sh
   ./scripts/rename_stage_files.sh include ./infrastructure/ecs_fargate stage3_files.list
   ```

1. **Plan the infrastructure changes**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu plan -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Apply the changes to deploy the infrastructure**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu apply -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Validate the (sub)domain with your DNS provider**: The output of the last `tofu apply` should give you the information you need to create a new record with your DNS provider. After you add this record, create a second CNAME record that points your (sub)domain at your load balancer URL. After AWS validates your (sub)domain (which may take about 5-30 minutes), proceed to the next step.

1. **Include stage 4 files**:

   ```sh
   ./scripts/rename_stage_files.sh include ./infrastructure/ecs_fargate stage4_files.list
   ```

1. **Plan the infrastructure changes**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu plan -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Apply the changes to deploy the infrastructure**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu apply -var-file="ecs_fargate_dev.tfvars"
   ```

1. **Test the API using https**: You should now be able to reach the API using https://<your-(sub)domain> rather than the load balancer URL.

1. **Delete ECR Images**: Once you've tested everything to your satisfaction, you can tear it all down. First, delete the ECR images using the delete_ecr_images.sh script. Be cautious with this script, as it will remove images from your registry.

   ```sh
   ./scripts/delete_ecr_images.sh ./infrastructure/ecs_fargate/ecs_fargate_dev.tfvars
   ```

1. **Delete Local Docker Images**: You may also want to clean up local Docker images to save space and maintain a tidy environment. Run the delete_local_docker_images.sh script to remove local Docker images created during the deployment process.

   ```sh
   ./scripts/delete_local_docker_images.sh ./infrastructure/ecs_fargate/ecs_fargate_dev.tfvars
   ```

1. **Destroy the AWS infrastructure**:

   ```sh
   ./scripts/run_tofu_in_infrastructure.sh ecs_fargate tofu destroy -var-file="ecs_fargate_dev.tfvars"
   ```

## Acknowledgments and Credits

This project was made possible thanks to the following resources:

- **Useful Article**: ["Hello, world - The Fargate/Terraform tutorial I wish I had" by Jimmy Sawczuk](https://section411.com/2019/07/hello-world/). This article provided invaluable guidance on deploying applications to AWS Fargate using Terraform.

- **External Libraries and Frameworks**:
  - [React](https://reactjs.org/)
  - [Vite](https://vitejs.dev/)
  - [Docker](https://www.docker.com/)
  - [OpenTofu](https://www.opentofu.org/)

- **API**:
  - [Open-Meteo API](https://open-meteo.com/): Open-Meteo is an open-source weather API that offers free access for non-commercial use, without requiring an API key. We use it for the /weather endpoint of the app.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
