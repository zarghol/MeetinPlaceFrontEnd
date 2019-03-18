//
//  SessionUser.swift
//  App
//
//  Created by Clément NONN on 11/03/2019.
//

import Vapor
import Authentication
import FluentSQLite

struct User: SQLiteUUIDModel, SessionAuthenticatable {
    var id: UUID? {
        get { return token }
        set { token = newValue }
    }

    var token: UUID!
    let isAdmin: Bool
    let username: String
}

extension User: Migration { }

extension User {
    var bearerAuth: String {
        return "Bearer \(token.uuidString)"
    }
}
