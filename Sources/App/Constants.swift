//
//  Constants.swift
//  App
//
//  Created by Clément NONN on 12/05/2019.
//

import Foundation

enum Constants {
    private static let bundle = Bundle.allFrameworks.first { $0.bundleIdentifier == "App" }
    static var versionNumber: String {
        guard let bundle = bundle,
            let versionNumber = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                return ""
        }

        return versionNumber
    }
}
