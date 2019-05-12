//
//  LocalizedView.swift
//  App
//
//  Created by Clément NONN on 12/05/2019.
//

import Foundation

protocol LocalizedView {
    var locale: Locale { get }
}

fileprivate enum LocaleCodingKeys: String, CodingKey {
    case locale
}

extension LocalizedView where Self: Encodable {
    func encodeLocale(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LocaleCodingKeys.self)
        try container.encode(locale.languageCode ?? "en", forKey: .locale)
    }
}
