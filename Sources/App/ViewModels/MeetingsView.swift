//
//  MeetingsView.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Foundation

struct MeetingsView: Encodable, LocalizedView {
    let meetings: [MeetingView]
    let connexionState: ConnectedState?
    let locale: Locale

    init(talks: [PublicTalk], connexionState: ConnectedState? = nil, locale: Locale) {
        let allTalks = [Date: [PublicTalk]](grouping: talks, by: { $0.presentationDate })

        self.meetings = allTalks.map { date, talks in MeetingView(talks: talks, date: date)}.sorted { $0.date > $1.date }
        self.connexionState = connexionState
        self.locale = locale
    }

    enum CodingKeys: String, CodingKey {
        case meetings
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(meetings, forKey: .meetings)
        try encodeLocale(with: encoder)
        if let connexionState = connexionState {
            try connexionState.encode(to: encoder)
        }
    }
}
