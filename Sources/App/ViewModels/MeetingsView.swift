//
//  MeetingsView.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Foundation

struct MeetingsView: Encodable {
    let meetings: [MeetingView]
    let connexionState: ConnectedState?

    init(talks: [PublicTalk], connexionState: ConnectedState? = nil) {
        let allTalks = [String: [PublicTalk]](grouping: talks, by: { $0.presentationDate })

        self.meetings = allTalks.map { date, talks in MeetingView(talks: talks, date: date)}
        self.connexionState = connexionState
    }

    enum CodingKeys: String, CodingKey {
        case meetings
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(meetings, forKey: .meetings)
        if let connexionState = connexionState {
            try connexionState.encode(to: encoder)
        }
    }
}
