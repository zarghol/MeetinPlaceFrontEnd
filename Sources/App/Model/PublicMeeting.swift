//
//  PublicMeeting.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

struct PublicMeeting {
    var title: String
    /// The date of the meeting
    var presentationDate: String
    /// the presenter that make the show 😎
    var presenter: String
}

extension PublicMeeting: Content { }


