import Leaf
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(LeafProvider())
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
    
    // Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Allow to use the session for auth purpose
    services.register(middlewares)
}
