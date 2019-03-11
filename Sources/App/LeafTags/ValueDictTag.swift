//
//  ValueDictTag.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Leaf

final class ValueDictTag: TagRenderer {
    init() { }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireParameterCount(3)
        try tag.requireNoBody()
        // #valueDict("meetings", meetingsByDate, date)
        guard let variableName = tag.parameters[0].string,
            let providedDict = tag.parameters[1].dictionary,
            let keyName = tag.parameters[2].string else {
            throw tag.error(reason: "Unsupported Key Type")
        }

        var dict = tag.context.data.dictionary ?? [:]
        dict[variableName] = providedDict[keyName]
        tag.context.data = .dictionary(dict)

        return Future.map(on: tag) { .null }
    }
}
