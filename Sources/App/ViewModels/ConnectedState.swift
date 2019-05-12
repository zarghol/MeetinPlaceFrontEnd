//
//  ConnectedState.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Foundation

enum ConnectedState: Encodable {
    case connected(username: String, createTalkOptions: CreateTalkView)
    case disconnected(version: String)

    enum CodingKeys: String, CodingKey {
        case username, isConnected, createTalkOptions, version
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .connected(let username, let createTalkOptions):
            try container.encode(username, forKey: .username)
            try container.encode(createTalkOptions, forKey: .createTalkOptions)
            try container.encode(true, forKey: .isConnected)
        case .disconnected(let version):
            try container.encode(false, forKey: .isConnected)
            try container.encode(version, forKey: .version)
        }
    }
}
