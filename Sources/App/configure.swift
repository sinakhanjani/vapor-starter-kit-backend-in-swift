import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    
    // Register NIOServerConfig
    let serverConfig = NIOServerConfig.default(hostname: "0.0.0.0")
    services.register(serverConfig)

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self) // Serves files from `Public` directory
    services.register(middlewares)

    // Configure a database
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(
      hostname: "localhost",
      username: "admin",
      database: "app",
      password: "474262")
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
        
    // Configure Authentication
    try services.register(AuthenticationProvider())
    var migrations = MigrationConfig()
    migrations.add(model: Admin.self, database: DatabaseIdentifier<Admin.Database>.psql)
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.psql)
    migrations.add(model: MagCategory.self, database: DatabaseIdentifier<MagCategory.Database>.psql)
    migrations.add(model: Mag.self, database: DatabaseIdentifier<Mag.Database>.psql)
    migrations.add(model: Tag.self, database: DatabaseIdentifier<Tag.Database>.psql)
    migrations.add(model: MagTagPivot.self, database: DatabaseIdentifier<MagTagPivot.Database>.psql)
    migrations.add(model: Authentication.self, database: DatabaseIdentifier<Authentication.Database>.psql)
    migrations.add(model: JWToken.self, database: DatabaseIdentifier<JWToken.Database>.psql)
    migrations.add(model: Message.self, database: DatabaseIdentifier<Message.Database>.psql)
    services.register(migrations)
    let maxBodySize = NIOServerConfig.default(maxBodySize: 200_000_000)
    services.register(maxBodySize)
}

// swift run Run --hostname 0.0.0.0 --port 9000
// vapor run --hostname=0.0.0.0 --port=8080
// DatabaseIdentifier<PostgreSQLDatabase>
