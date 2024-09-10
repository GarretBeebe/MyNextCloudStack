# NextCloud with Postgres and Redis
  This repository contains a Docker Compose configuration for setting up a Nextcloud deployment with Redis and Postgres. It also includes an initialization script to configure the postgres container.

# Prerequisites
Before you start, ensure you have the following installed:

Docker (version 20.10 or higher)
Docker Compose (version 1.27 or higher)

# Getting Started
Clone the Repository

```bash
git clone https://github.com/GarretBeebe/MyNextCloudStack.git
cd MyNextCloudStack
```
# Configuration

Make sure to configure any necessary environment variables. Copy the env.example file to .env and adjust the values as needed:

```bash
cp .env.example .env
```
# Start the Services

Use Docker Compose to build and start the services defined in docker-compose.yml:

```bash
docker-compose up --build
```

By default, this will start the containers in the foreground. To run them in the background, add the -d flag:

```bash
docker-compose up --build -d
```

# Access the Application

After starting the services, you can access your application at http://localhost:5080 (or the port specified in your docker-compose.yml file).

# Stopping the Services

To stop and remove the running containers, use:

```bash
docker-compose down
```
# Logs

View logs for all services with:

```bash
docker-compose logs
```

To view logs for a specific service, use:

```bash
docker-compose logs <service-name>
```

# License
This project is licensed under the MIT License.

# Contact
For any questions or issues, please contact garret.beebe@gmail.com
