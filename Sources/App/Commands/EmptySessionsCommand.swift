//
//  EmptySessionsCommand.swift
//  App
//
//  Created by Clément NONN on 15/04/2019.
//

import Vapor
import FluentSQLite

struct EmptySessionsCommand: Command {
    var arguments: [CommandArgument] { return [] }

    var options: [CommandOption] { return [] }

    var help: [String] { return ["clear all sessions in the cache"] }

    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let logger = try context.container.make(Logger.self)
        logger.info("trying to clear all sessions in cache...")
        return context.container.withPooledConnection(to: .sqlite) { connection in
            return User.query(on: connection).all().map {
                logger.info("sessions to clear : \($0.count)")
                try $0.forEach {
                    try $0.delete(on: connection).wait()
                }
                logger.info("alright, sessions cleared !")
            }
        }
    }
}
