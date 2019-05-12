//
//  Controller.swift
//  App
//
//  Created by Clément NONN on 18/03/2019.
//

import Vapor

final class Controller {
    func meetings(_ req: Request) throws -> Future<View> {
        let api = try req.make(APIInterface.self)
        return api.usernames().map { usernames in
            if let user = try req.authenticated(User.self) {
                return .connected(
                    username: user.username,
                    createTalkOptions: CreateTalkView(isAdmin: user.isAdmin, presenters: usernames))
            } else {
                return .disconnected(version: Constants.versionNumber)
            }
            }.and(api.talks())
            .flatMap { connexionState, talks in
                return try req.view().render("allMeetings", MeetingsView(talks: talks, connexionState: connexionState, locale: req.locale))
        }
    }

    func connexion(_ req: Request) throws -> Future<Response> {
        guard try !req.isAuthenticated(User.self) else {
            return req.future(req.redirect(to: "home"))
        }
        return try req.view().render("connexion", ConnectedState.disconnected(version: Constants.versionNumber)).map {
            return req.response($0.data, as: .html)
        }
    }

    func connect(_ req: Request) throws -> Future<Response> {
        let userRequest = try req.content.decode(PublicUserRequest.self)

        return userRequest.flatMap(to: User.self) { request in
            let api = try req.make(APIInterface.self)
            return api.connexion(userRequest: request)
        }.with {
            User.query(on: req).filter(\User.token, .equal, $0.token).first()
        }.flatMap(to: User.self) {
            if let existingUser = $1 {
                return req.future(existingUser)
            } else {
                return $0.create(on: req)
            }
        }.map {
            try req.authenticate($0)
        }
        .transform(to: req.redirect(to: "home"))
        .catchFlatMap({ error in
            let errorText: String = (error as? Debuggable)?.reason ?? "\(error)"
            return try req.view().render("connexion", ConnexionErrorView(error: errorText)).map(to: Response.self) {
                return req.response($0.data, as: .html)
            }
        })
    }

    func disconnect(_ req: Request) throws -> Future<Response> {
        guard let user = try req.authenticated(User.self) else {
            return req.future(req.redirect(to: "/"))
        }

        try req.unauthenticate(User.self)
        return user.delete(on: req)
            .map { req.redirect(to: "/") }
    }

    func myMeetings(_ req: Request) throws -> Future<Response> {
        guard let user = try req.authenticated(User.self) else {
            return req.future(req.redirect(to: "/"))
        }

        let api = try req.make(APIInterface.self)
        return api.myTalks(user: user).and(api.usernames()).flatMap { talks, usernames in
            return try req.view().render("myMeetings", HomeView(
                meetingsView: MeetingsView(talks: talks, locale: req.locale),
                connexionState: .connected(
                    username: user.username,
                    createTalkOptions: CreateTalkView(isAdmin: user.isAdmin, presenters: usernames)
                ),
                locale: req.locale
            ))
        }.map { view in
            return req.response(view.data, as: .html)
        }
    }

    func createTalk(_ req: Request) throws -> Future<Response> {
        guard let user = try req.authenticated(User.self) else {
            return req.future(req.redirect(to: "/"))
        }
        let api = try req.make(APIInterface.self)

        return try req.content.decode(PublicTalkRequest.self).flatMap {
            api.createTalk(talkRequest: $0, user: user)
        }.map { _ in
            req.redirect(to: "home")
        }
    }
}
