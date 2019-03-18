//
//  HomeView.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Foundation

struct HomeView: Encodable {
    let meetingsView: MeetingsView
    let connexionState: ConnectedState

    enum CodingKeys: String, CodingKey {
        case meetingsView, createTalkOptions
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(meetingsView, forKey: .meetingsView)
        try connexionState.encode(to: encoder)
    }
}
