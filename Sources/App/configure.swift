import Leaf
import Vapor
import Authentication
import FluentSQLite

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(LeafProvider())
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    services.register(APIInterface.self)

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    services.register { container -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(ValueDictTag(), as: "valueDict")
        return config
    }

    let inMemoryDB = try SQLiteDatabase(storage: SQLiteStorage.memory)

    var databases = DatabasesConfig()
    databases.add(database: inMemoryDB, as: .sqlite)
    services.register(databases)
    
    // Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Commands

    var commandConfig = CommandConfig.default()
    commandConfig.use(EmptySessionsCommand(), as: "clearSessions")
    services.register(commandConfig)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Allow to use the session for auth purpose
    services.register(middlewares)

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    services.register(migrations)
}
