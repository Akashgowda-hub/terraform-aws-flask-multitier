# Terraform AWS Flask Multi-Tier Application

## Project Overview

This project demonstrates the evolution of a Flask web application from a simple monolithic architecture to a three-tier architecture using AWS services and Terraform.

The main objective of this project is to understand how applications can be deployed on AWS, how infrastructure can be managed using Infrastructure as Code (IaC), and how different architectural approaches improve scalability, security, and maintainability.

The project is divided into three stages:

- **01-tier-monolith:** A basic Flask application deployed on an EC2 instance.
- **02-tier-rds:** A Flask application hosted on EC2 with Amazon RDS as the database layer.
- **03-tier-separated:** A three-tier architecture with a separate frontend, backend API, and database.

Each stage builds on the previous one and introduces concepts used in real-world cloud infrastructure.

## Technologies Used

| Technology | Purpose |
| --- | --- |
| AWS | Cloud infrastructure and application hosting |
| Terraform | Infrastructure provisioning and management |
| Amazon EC2 | Running the Flask application and backend services |
| Amazon RDS | Managed relational database |
| Amazon S3 | Hosting static frontend files |
| Application Load Balancer (ALB) | Distributing HTTP traffic to backend instances |
| Auto Scaling Group (ASG) | Managing the number of backend instances |
| AWS Secrets Manager | Secure storage of database credentials |
| AWS Systems Manager (SSM) | Managing EC2 instances without relying on SSH |
| Amazon VPC | Providing an isolated network for application resources |
| Security Groups | Controlling network traffic between AWS resources |
| Python and Flask | Building the backend application |
| PostgreSQL | Storing application data |
| HTML, CSS, and JavaScript | Building the frontend interface |
| Gunicorn | Running the Flask application as a production-oriented WSGI server |
| Linux | Operating system for EC2 instances |

## Project Structure

The repository contains three separate implementations.

### 01\. Monolithic Architecture

The first implementation keeps the application and its presentation logic together in a single Flask application.

### 02\. Application with a Separate Database

The second implementation introduces Amazon RDS, separating the application runtime from persistent database storage.

### 03\. Three-Tier Architecture

The third implementation separates the frontend, backend API, and database into distinct layers, with AWS services responsible for hosting, networking, security, and scalability.

This structure makes it easier to understand how application architecture evolves as requirements become more advanced.

---

# 1\. Monolithic Architecture

**Directory:** `01-tier-monolith`

## Overview

The monolithic architecture is the starting point of this project.

In this approach, the Flask application, user interface, and application logic are maintained together. The application runs on an Amazon EC2 instance and serves web pages directly to users.

Terraform is used to provision the AWS resources required to run the application.

## AWS Services Used

### Amazon EC2

Amazon EC2 provides the virtual server on which the Flask application runs.

The instance hosts the Python application and its dependencies. Users access the application through the instance's network endpoint.

### Terraform

Terraform manages the infrastructure required by this architecture.

It defines the AWS resources in configuration files, making the infrastructure easier to reproduce and maintain.

### Security Groups

Security groups control which network connections are allowed to reach the EC2 instance.

They help restrict access to the application and other exposed services.

## Application Components

The `app` directory contains the Flask application, its Python dependencies, and the HTML templates.

- `app.py` contains the application logic and routes.
- `requirements.txt` lists the Python packages required by the application.
- `templates/index.html` provides the main user interface.
- `templates/edit.html` provides the interface for editing application data.

The `Scripts` directory contains supporting deployment files.

- `deploy.sh` assists with application deployment.
- `flaskapp.service` defines the systemd service used to manage the Flask application.

The Terraform configuration files define the AWS infrastructure, input variables, and output values.

## How It Works

A user accesses the application through the EC2 instance's endpoint.

The Flask application processes the request, performs the required operations, and returns the resulting web page.

Because the application and presentation logic run together, the architecture is straightforward to understand and suitable for learning the fundamentals of deploying Python applications on AWS.

## Limitations

Although a monolithic architecture is simple to deploy, it has some limitations:

- The application and its components are closely connected.
- Scaling the application independently from other components is difficult.
- Application availability depends heavily on the individual server.
- Application deployment and infrastructure changes can become more complicated as the project grows.

These limitations provide the motivation for introducing a separate database layer.

---

# 2\. Architecture with Amazon RDS

**Directory:** `02-tier-rds`

## Overview

The second implementation improves the original architecture by separating the application server from the database.

The Flask application continues to run on Amazon EC2, but persistent application data is stored in Amazon RDS.

This separation introduces an important cloud architecture concept: the application and database can be managed independently.

## AWS Services Used

### Amazon EC2

EC2 continues to host the Flask application.

It handles incoming requests, executes application logic, and communicates with the database when data needs to be read or updated.

### Amazon RDS

Amazon RDS provides a managed relational database service.

Instead of maintaining the database directly on the application server, the database runs as a separate AWS resource.

This offers several advantages:

- Application data is stored separately from the application runtime.
- Database backups and maintenance can be managed through the RDS service.
- Database resources can be managed independently of the EC2 instance.
- Replacing or updating the application server does not inherently require replacing the database.

### Amazon VPC

The VPC provides the network environment in which the application and database communicate.

Network configuration helps control how the different components access one another.

### Security Groups

Security groups restrict network access between the application and database.

For example, the database can be configured to accept PostgreSQL connections from the application server's security group rather than allowing unrestricted access.

### Terraform

Terraform provisions the infrastructure, including the application server, database, and supporting network resources.

It also makes it easier to keep the infrastructure configuration consistent.

## Application Components

The application remains a Flask application with HTML templates.

The main files include:

- `app/app.py` — application logic.
- `app/requirements.txt` — Python dependencies.
- `app/templates/index.html` — main application interface.
- `app/templates/edit.html` — editing interface.
- `user_data.sh` — EC2 initialization and application setup.
- `main.tf` — primary infrastructure configuration.
- `variables.tf` — configurable infrastructure inputs.
- `outputs.tf` — useful values produced by Terraform.

## How It Works

A user sends a request to the Flask application running on EC2.

The application processes the request and connects to Amazon RDS when database operations are required.

The database returns the requested information or stores the updated data, and the application generates the appropriate response.

The application server and database have separate responsibilities.

EC2 runs the application, while RDS manages persistent relational data.

## Why This Architecture Is Better

Compared with the monolithic implementation, this architecture provides a clearer separation of responsibilities.

The database is no longer tied to the lifecycle of the application server.

This is an important step toward building applications that are easier to maintain and expand.

However, the application is still deployed as a single application component, and the frontend remains closely associated with the Flask application.

The next stage addresses this by separating the frontend and backend.

---

# 3\. Three-Tier Architecture

**Directory:** `03-tier-separated`

## Overview

The third implementation introduces a three-tier architecture using AWS services and Terraform.

The application is divided into three logical layers:

1. **Presentation tier:** The frontend that users interact with.
2. **Application tier:** The Flask backend API that processes requests.
3. **Data tier:** The PostgreSQL database that stores application data.

Each layer has a separate responsibility.

The frontend is hosted on Amazon S3, the backend runs on Amazon EC2 instances behind an Application Load Balancer, and the database runs on Amazon RDS.

AWS Secrets Manager is used to manage database credentials, while AWS Systems Manager provides an alternative to relying on SSH for instance management.

This architecture provides a more modular foundation for building and operating cloud applications.

## Architecture Components

### 3.1 Presentation Tier — Amazon S3

**Directory:** `03-tier-separated/frontend`

The frontend is built using HTML, CSS, and JavaScript.

Amazon S3 hosts the static frontend files, allowing the user interface to be served separately from the backend application.

The frontend consists of:

- `index.html` — the main application page.
- `style.css` — styling and layout.
- `app.js` — frontend logic and communication with the backend API.

The JavaScript code sends HTTP requests to the backend API to retrieve, create, and delete todo items.

The frontend does not need to run Flask or connect directly to PostgreSQL.

Instead, it communicates with the backend through HTTP requests.

**Why Amazon S3?**

Amazon S3 provides a simple way to host static website files without maintaining a web server for the frontend.

It separates frontend deployment from backend deployment and reduces the need to run application servers solely to serve static content.

For this project, the frontend uses S3 static website hosting. This is suitable for a learning environment, although production deployments generally require additional considerations such as HTTPS, a content delivery network, and appropriate access controls.

### 3.2 Application Tier — Amazon EC2

**Directory:** `03-tier-separated/backend`

The application tier contains the Flask REST API.

It processes requests received from the frontend, interacts with the database, and returns responses in JSON format.

The backend files include:

- `app.py` — Flask API implementation.
- `requirements.txt` — Python dependencies.

The application uses Flask to define HTTP endpoints and Psycopg to communicate with PostgreSQL.

Gunicorn runs the Flask application as the application server.

**Why Amazon EC2?**

EC2 provides the compute capacity required to run the backend application.

It allows control over the operating system, application runtime, installed packages, and service configuration.

The backend instances are managed through an Auto Scaling Group, which provides a mechanism for maintaining and adjusting the number of instances.

### 3.3 Application Load Balancer

The Application Load Balancer provides an entry point for incoming backend HTTP requests.

Instead of requiring users to communicate directly with individual EC2 instances, the frontend sends API requests to the load balancer.

The load balancer forwards requests to registered backend instances according to its listener and target group configuration.

The target group includes health checks that help determine whether registered instances are healthy.

**Why use an Application Load Balancer?**

The load balancer separates the public API endpoint from individual backend instances.

It provides a central entry point for backend traffic and supports distributing requests across multiple instances.

It also integrates with the Auto Scaling Group, allowing backend capacity to change without requiring the frontend to use a different API endpoint every time instances change.

### 3.4 Auto Scaling Group

The Auto Scaling Group manages the EC2 instances used by the backend.

It works with a launch template that describes how new application instances should be configured.

When the group needs to launch or replace instances, the launch template provides the required instance configuration.

The project also includes an instance refresh configuration to support rolling replacement of instances when the launch template changes.

**Why use Auto Scaling?**

It provides a foundation for maintaining backend capacity and replacing instances when necessary.

It also makes it possible to adjust the number of instances according to configured scaling policies and capacity requirements.

Auto Scaling does not automatically guarantee high availability. The actual availability depends on factors such as subnet placement, health checks, scaling configuration, and application readiness.

### 3.5 Data Tier — Amazon RDS

The database tier uses Amazon RDS to store application data in PostgreSQL.

The database is separate from the frontend and backend compute resources.

The Flask API connects to PostgreSQL to retrieve, create, and delete todo records.

The application initializes the `todos` table if it does not already exist.

The table contains an ID and a title for each todo item.

**Why Amazon RDS?**

Amazon RDS provides a managed database service rather than requiring the project to maintain PostgreSQL directly on an EC2 instance.

It separates data storage from the application runtime and provides AWS-managed database administration capabilities.

The database can also be protected through appropriate network rules, credentials, backups, and database configuration.

### 3.6 AWS Secrets Manager

AWS Secrets Manager stores the database password separately from the main Terraform application configuration.

The secret used in this project is named:

`flask-3tier-lab/database/password`

The secret is referenced by its Amazon Resource Name (ARN) in the Terraform configuration.

During EC2 initialization, the instance retrieves the secret and makes the database password available to the Flask application through its environment configuration.

**Why use Secrets Manager?**

Database credentials should not be embedded directly into application source code or committed to a Git repository.

Secrets Manager provides a dedicated location for storing and managing sensitive values.

This separation makes credential management more organized and supports security practices such as restricting access through IAM permissions.

The EC2 instance must have the appropriate IAM permissions to retrieve the secret. The secret's encryption key permissions and other access policies must also allow the operation.

### 3.7 AWS Systems Manager

AWS Systems Manager is used to manage EC2 instances without depending on a direct SSH connection.

The EC2 initialization script installs and starts the SSM Agent.

When the instance has the required IAM permissions, network connectivity, and agent configuration, it can register with Systems Manager and support management through AWS tools.

**Why use Systems Manager?**

Traditional SSH-based administration requires managing access to the instance through SSH credentials and network rules.

Systems Manager provides an alternative management mechanism that can reduce the need to expose SSH access.

For this functionality to work, the EC2 instance needs an appropriate IAM instance profile and connectivity to the relevant Systems Manager endpoints.

Installing the agent alone is not sufficient.

### 3.8 Amazon VPC and Security Groups

The VPC provides the networking environment for the application.

The infrastructure separates network responsibilities and uses security groups to control communication between components.

For example:

- The frontend communicates with the backend through the configured API endpoint.
- The Application Load Balancer forwards requests to the backend instances.
- The backend instances communicate with PostgreSQL on the database port.
- The database should accept connections only from the intended application resources.

This separation helps limit unnecessary network access.

The actual security of the architecture depends on the configured ingress and egress rules, subnet routing, public accessibility settings, and IAM policies.

---

# 4\. How the Three-Tier Application Works

The request flow is straightforward.

**Step 1: User opens the frontend**

The user accesses the static website hosted on Amazon S3.

The browser downloads the HTML, CSS, and JavaScript files.

**Step 2: Frontend communicates with the backend**

When the user interacts with the application, JavaScript sends HTTP requests to the backend API.

For example, the frontend can request the existing todo items.

**Step 3: Application Load Balancer receives the request**

The API request reaches the Application Load Balancer, which forwards it to a registered backend instance.

**Step 4: Flask processes the request**

The Flask application receives the request and determines the required operation.

For database operations, it establishes a connection to PostgreSQL using the configured database credentials.

**Step 5: Amazon RDS handles the database operation**

PostgreSQL retrieves, creates, or deletes the requested records.

**Step 6: Backend returns a response**

The Flask API returns the result as JSON.

**Step 7: Frontend updates the interface**

The JavaScript code processes the response and updates the page to reflect the latest application data.

This flow keeps the user interface, application logic, and data storage separate.

---

# 5\. Backend API Endpoints

The Flask backend exposes the following API endpoints.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/health` | Checks whether the backend is responding |
| GET | `/api/todos` | Retrieves all todo items |
| POST | `/api/todos` | Creates a new todo item |
| DELETE | `/api/todos/<todo_id>` | Deletes a todo item by its ID |

### Health Check

The `/health` endpoint returns a simple JSON response indicating that the application is running.

This endpoint can also be used by the Application Load Balancer for target health checks.

A successful response confirms that the Flask endpoint is responding. It does not necessarily prove that every application dependency is healthy.

### Retrieve Todo Items

The `/api/todos` endpoint retrieves todo records from PostgreSQL.

The response contains a JSON array of todo items.

When there are no records, the API returns an empty array.

### Create a Todo Item

The `POST /api/todos` endpoint accepts a todo title in a JSON request body.

The backend validates the title and inserts the new record into PostgreSQL.

If the request is valid, the API returns the created todo item.

### Delete a Todo Item

The `DELETE /api/todos/<todo_id>` endpoint deletes a todo record using its ID.

If the record does not exist, the API returns a not-found response.

---

# 6\. Terraform and Infrastructure as Code

Terraform is used throughout the project to define and manage AWS infrastructure.

Instead of creating every resource manually through the AWS Management Console, infrastructure is described in configuration files.

This approach makes the infrastructure easier to understand, reproduce, review, and maintain.

In the three-tier implementation, the Terraform directory separates the infrastructure into several files.

| File | Responsibility |
| --- | --- |
| `versions.tf` | Defines Terraform and provider requirements |
| `variables.tf` | Declares configurable infrastructure inputs |
| `network.tf` | Defines network resources |
| `security_groups.tf` | Defines network access rules |
| `database.tf` | Defines database-related resources |
| `compute.tf` | Defines backend compute resources, the launch template, load balancer, and Auto Scaling configuration |
| `frontend.tf` | Defines frontend hosting resources |
| `routing.tf` | Defines routing and load-balancer listener configuration |
| `outputs.tf` | Exposes useful infrastructure information |

This separation keeps related resources organized and makes the configuration easier to navigate.

Terraform also helps maintain a consistent relationship between resources. For example, the backend configuration can reference the database endpoint and the secret ARN rather than relying on manually copied values.

The Terraform state file tracks the resources managed by Terraform. It can contain sensitive infrastructure information and should be protected from unauthorized access.

---

# 7\. EC2 Initialization and Application Deployment

The three-tier architecture uses an EC2 initialization script named `user_data.sh.tftpl`.

This template is used by Terraform to configure backend instances when they launch.

The initialization process performs several tasks.

### Operating System Preparation

The script updates the package information and installs the required system packages.

These packages provide the environment needed to install and run the Python application.

### AWS CLI Installation

The script installs AWS CLI v2 so the instance can interact with supported AWS services through the command-line interface.

### Systems Manager Agent

The script installs and starts the SSM Agent when it is not already installed.

The instance still requires the appropriate IAM role and network connectivity for Systems Manager functionality.

### Python Application Setup

The script places the Flask application and its dependency file on the instance.

It creates a Python virtual environment and installs the required packages.

This keeps the application's Python dependencies separate from the system Python environment.

### Database Configuration

The script configures the database connection information and retrieves the database password from AWS Secrets Manager.

It then uses the configured credentials to connect to PostgreSQL and initialize the `todos` table if necessary.

### Systemd Service

The script creates a systemd service named `flask3tier`.

This service runs Gunicorn, which serves the Flask application on port `8000`.

Systemd is configured to start the application at boot and restart the service if the process exits.

This allows the backend application to run as a managed Linux service instead of requiring someone to start it manually.

---

# 8\. Security Considerations

Security is an important part of the project, particularly when the application communicates with a database and uses AWS-managed services.

The architecture incorporates several security-related practices.

### Credential Management

The database password is stored in AWS Secrets Manager rather than directly in the Flask source code.

Access to the secret should be restricted to the IAM roles and users that require it.

### Network Isolation

Security groups control which resources can communicate with one another.

The database should not be unnecessarily exposed to public network access.

### Instance Management

AWS Systems Manager provides a way to manage supported EC2 operations without relying entirely on direct SSH access.

### Database Access

The backend should be the intended source of database connections.

The frontend should never receive or use database credentials directly.

### Terraform State Protection

Terraform state files may contain sensitive values and infrastructure details.

They should not be treated as ordinary source files. A production setup should use an appropriately secured remote state backend and restrict access to the state.

### Production Considerations

This project is a learning implementation. Before using a similar architecture in production, additional controls should be evaluated, including:

- HTTPS for public application traffic.
- Appropriate frontend hosting and content delivery configuration.
- Encryption and access controls for stored data.
- Restricted IAM permissions.
- Database backup and recovery policies.
- Monitoring, logging, and alerting.
- Secure handling of Terraform state and plan files.
- Appropriate database and network availability configurations.

---

# 9\. Challenges and Lessons Learned

Building this project helped demonstrate that deploying a cloud application involves more than running application code on a virtual machine.

The application depends on networking, IAM permissions, database connectivity, infrastructure configuration, and application routing.

Some of the important lessons from the project include the following.

### Understanding Application Routing

A backend can be running correctly while the root URL returns a `404 Not Found` response.

In this project, the Flask application exposes routes such as `/health` and `/api/todos`, rather than defining a route for `/`.

Therefore, accessing the root URL of the backend load balancer does not automatically display the frontend.

The frontend is hosted separately on Amazon S3, while the backend serves API endpoints.

### Managing Secrets

Creating an AWS Secrets Manager secret through Terraform can fail if a secret with the same name already exists.

This highlights the importance of understanding the relationship between existing AWS resources and Terraform state.

Existing resources may need to be imported into Terraform state when they are intended to be managed by the current configuration.

### Troubleshooting Backend Availability

A running systemd service does not necessarily mean the entire application is accessible through the load balancer or frontend.

Troubleshooting requires checking the application process, API endpoints, load-balancer health checks, network access, and database connectivity.

Testing these components individually helps identify where a problem occurs.

### Understanding Terraform Changes

Terraform configurations describe the desired infrastructure, but changing a configuration does not necessarily mean an existing EC2 instance has immediately adopted the new configuration.

Launch template changes, instance replacement, and Auto Scaling behavior must be considered when updating deployed applications.

### Understanding Git History

Version control is an important part of infrastructure development.

Git allows infrastructure and application changes to be tracked, reviewed, and maintained alongside the project.

The repository history also provides a record of how the architecture and implementation evolved.

---

# 10\. Comparison of the Three Architectures

| Feature | Monolithic | Application with RDS | Three-Tier |
| --- | --- | --- | --- |
| Application hosting | EC2 | EC2 | EC2 behind an ALB |
| Frontend | Flask templates | Flask templates | Static files hosted on S3 |
| Backend | Flask application | Flask application | Separate Flask REST API |
| Database | Application architecture's initial implementation | Amazon RDS | Amazon RDS |
| Application Load Balancer | Not a defining component | Not a defining component | Used for backend traffic |
| Auto Scaling | Not a defining component | Not a defining component | Auto Scaling Group |
| Credential management | Depends on implementation | Depends on implementation | AWS Secrets Manager |
| Instance management | Linux administration | Linux administration | SSM Agent and Systems Manager integration |
| Infrastructure management | Terraform | Terraform | Terraform |
| Separation of responsibilities | Limited | Application and database separated | Frontend, backend, and database separated |
| Complexity | Low | Moderate | Higher |
| Scalability options | Limited | Improved database separation | More flexible backend scaling |

The key difference is not simply the number of AWS services used.

Each stage introduces a different level of separation between application components.

The monolithic implementation focuses on basic application deployment. The second stage separates persistent data from the application server. The third stage separates the presentation, application, and data layers and introduces additional infrastructure for managing backend traffic and capacity.

---

# 11\. What I Learned from This Project

Through this project, I explored several important AWS and DevOps concepts:

- Deploying Python applications on Amazon EC2.
- Building cloud infrastructure with Terraform.
- Understanding the differences between monolithic and multi-tier architectures.
- Separating application logic from persistent database storage.
- Hosting static frontend files on Amazon S3.
- Connecting a JavaScript frontend to a Flask REST API.
- Using an Application Load Balancer to route requests to backend instances.
- Managing EC2 instances through an Auto Scaling Group.
- Storing database credentials in AWS Secrets Manager.
- Understanding the requirements for AWS Systems Manager access.
- Configuring communication between application and database resources.
- Using Linux services and Gunicorn to run a Flask application.
- Troubleshooting application routes, HTTP errors, and infrastructure issues.
- Managing infrastructure changes and Git history.

The project also helped me understand how infrastructure, application code, networking, and security work together in a cloud environment.

---

# 12\. Conclusion

This project demonstrates the progression from a basic Flask application to a more modular, three-tier cloud architecture.

The first implementation establishes the fundamentals of deploying an application on EC2.

The second introduces Amazon RDS to separate application execution from persistent data storage.

The third brings these concepts together with a separately hosted frontend, a Flask REST API, an Application Load Balancer, an Auto Scaling Group, and AWS-managed database and secret-management services.

Terraform provides a consistent way to define and manage the infrastructure across these implementations.

Overall, this project serves as a practical learning experience in AWS, Terraform, Python application deployment, networking, security, and cloud architecture.

The main takeaway is that a reliable cloud application depends not only on the application itself, but also on how its infrastructure, networking, credentials, and individual components are designed and managed.

---

## Repository

**Project:** Terraform AWS Flask Multi-Tier Application

**Repository:** terraform-aws-flask-multitier

**Main technologies:** AWS, Terraform, Python, Flask, PostgreSQL, Amazon EC2, Amazon RDS, Amazon S3, Application Load Balancer, Auto Scaling, AWS Secrets Manager, and AWS Systems Manager.