//
//  SessionUser.swift
//  App
//
//  Created by Clément NONN on 11/03/2019.
//

import Vapor
import Authentication

struct User: Codable, SessionAuthenticatable {
    var sessionID: String? {
        return token
    }

    static func authenticate(sessionID: String, on connection: DatabaseConnectable) -> EventLoopFuture<User?> {
        return connection.future(User(token: sessionID, isAdmin: false, username: ""))
    }

    let token: String
    let isAdmin: Bool
    let username: String
}
