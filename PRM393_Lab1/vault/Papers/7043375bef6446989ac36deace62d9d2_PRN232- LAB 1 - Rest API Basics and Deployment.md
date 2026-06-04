
# LAB 1 – REST API Technical Requirements & Design Standards (PRN232)

## Abstract
This paper outlines the technical requirements and design standards for a Learning Management System (LMS) RESTful API using a 3-layer architecture.

## Introduction
The assignment requires developing an ASP.NET Core RESTful API for a Learning Management System (LMS) with a 3-layer architecture, including API Layer, Service Layer, and Repository Layer.

## Methods
The project must use a 3-layer architecture, with clear separation of responsibilities between layers. The API Layer must not contain business logic, and the Repository Layer must not contain business logic. The project must also use 4 model types: Entity Model, Business Model, Request Model, and Response Model.

## Results
The API must follow RESTful principles, use resource-based endpoints, and use plural nouns in URLs. The API must also support searching, sorting, paging, selection, and expansion capabilities. The API must return a consistent response format, including pagination metadata.

## Discussion
The API must be deployed using Docker Desktop, with the database running using Docker containers. The project must include a Dockerfile and a docker-compose.yml file. Swagger/OpenAPI integration is also required, supporting endpoint listing, API testing, request/response documentation, and HTTP status code documentation.

## Concepts
- [[3-layer architecture]]
- [[RESTful API design]]
- [[Entity Model]]
- [[Business Model]]
- [[Request Model]]
- [[Response Model]]
- [[Docker deployment]]
- [[Swagger/OpenAPI integration]]
