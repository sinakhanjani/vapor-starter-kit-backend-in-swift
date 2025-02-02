# Vapor Starter Kit - Backend in Swift

A simple and efficient backend starter project built with **Swift** using the **Vapor** framework. This project provides a foundation for building RESTful APIs with essential configurations, authentication, and database integration.

## Features

- ✅ Built with **Swift** and **Vapor**
- ✅ RESTful API structure
- ✅ Authentication & JWT support
- ✅ Database integration (PostgreSQL/MySQL/SQLite)
- ✅ Environment configuration handling
- ✅ Dependency injection with `Service`
- ✅ Middleware support
- ✅ Docker support (optional)

## Getting Started

### Prerequisites

- Install [Swift](https://swift.org/download/)
- Install [Vapor Toolbox](https://docs.vapor.codes/getting-started/install-macos/)
- Setup your preferred database (PostgreSQL, MySQL, or SQLite)

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/sinakhanjani/vapor-starter-kit-backend-in-swift.git
   cd vapor-starter-kit-backend-in-swift
   ```

2. Install dependencies:
   ```sh
   swift package update
   swift package resolve
   ```

3. Setup environment variables:
   ```sh
   cp .env.example .env
   ```
   Edit `.env` and configure your database credentials.

4. Run migrations (if applicable):
   ```sh
   vapor run migrate
   ```

5. Start the server:
   ```sh
   vapor run serve
   ```
   The API will be available at `http://localhost:8080`.

## Project Structure

```
├── Sources/
│   ├── App/
│   │   ├── Controllers/
│   │   ├── Models/
│   │   ├── Config/
│   │   ├── Routes.swift
│   │   ├── Middleware.swift
│   │   ├── main.swift
│   ├── Run/
│   │   ├── main.swift
├── Public/
├── Resources/
├── Tests/
├── Package.swift
├── README.md
```

## API Endpoints

| Method | Endpoint         | Description           |
|--------|----------------|----------------------|
| GET    | `/api/ping`    | Health check        |
| POST   | `/api/login`   | User authentication |
| GET    | `/api/users`   | List all users      |
| POST   | `/api/users`   | Create a new user   |

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

For any questions, reach out to [@sinakhanjani](https://github.com/sinakhanjani).
