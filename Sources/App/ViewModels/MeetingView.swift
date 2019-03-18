//
//  MeetingView.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Foundation

struct MeetingView: Encodable {
    let talks: [PublicTalk]
    let date: String
}
