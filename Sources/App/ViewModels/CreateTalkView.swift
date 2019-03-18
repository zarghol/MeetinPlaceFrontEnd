//
//  CreateTalkView.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Foundation

struct CreateTalkView: Encodable {
    let isAdmin: Bool
    let presenters: [String]
}
