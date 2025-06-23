# CustomerUpdate Java Spring Boot Backend

This is a Java Spring Boot rewrite of the original .NET CustomerUpdate backend.

## Features
- Customer CRUD API
- AS400 validation stub (ready for ODBC integration)
- H2 in-memory database for development
- Health check endpoint

## Requirements
- Java 17+
- Maven 3.8+

## Getting Started

### 1. Build the project
```sh
mvn clean install
```

### 2. Run the application
```sh
mvn spring-boot:run
```

The API will be available at: `http://localhost:8080`

### 3. H2 Database Console
- Visit: `http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:mem:customerdb`
- User: `sa` (no password)

## API Endpoints

### Health
- `GET /api/health` — Returns API health status

### Customers
- `GET /api/customers` — List all customers
- `GET /api/customers/{id}` — Get customer by ID
- `POST /api/customers` — Create customer
- `PUT /api/customers/{id}` — Update customer
- `DELETE /api/customers/{id}` — Delete customer
- `GET /api/customers/validate-tax-id/{taxId}` — Check if Tax ID exists

## AS400 Validation
- The AS400 validation is currently stubbed. Integrate ODBC logic in `As400ValidationService` as needed.

## Docker (Optional)
To run in Docker, add a Dockerfile and build with:
```sh
docker build -t customerupdate-backend .
docker run -p 8080:8080 customerupdate-backend
```

---

For questions or issues, please contact the maintainer. 