//
//  PublicUser.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

struct PublicUser {
    var username: String
}

extension PublicUser: Content { }

struct PublicUserRequest {
    var user: String
    var password: String
}

extension PublicUserRequest {
    var basicAuth: String {
        let basicString = "\(user):\(password)"
        let base64Encoded = basicString.convertToData().base64EncodedString()
        return "Basic \(base64Encoded)"
    }
}

extension PublicUserRequest: Content { }
