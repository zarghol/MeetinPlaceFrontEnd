//
//  Request+locale.swift
//  App
//
//  Created by Clément NONN on 12/05/2019.
//

import Vapor

extension Request {
    var locale: Locale {
        guard let accepted = self.http.headers.firstValue(name: .acceptLanguage) else {
            return Locale.current
        }
        return Locale(identifier: accepted)
    }
}
