import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let controller = Controller()

    let authGroup = router.grouped(User.authSessionsMiddleware())

    router.get("meetings", use: controller.meetings)

    authGroup.get(use: controller.connexion)
    authGroup.post("connexion", use: controller.connect)
    authGroup.get("home", use: controller.myMeetings)
}

final class Controller {
    func meetings(_ req: Request) throws -> Future<View> {
        let api = try req.make(APIInterface.self)
        return api.talks().flatMap { talks in
            return try req.view().render("allMeetings", MeetingsView(talks: talks))
        }
    }

    func connexion(_ req: Request) throws -> Future<Response> {
        guard try !req.isAuthenticated(User.self) else {
            return req.future(req.redirect(to: "home"))
        }
        return try req.view().render("connexion").map {
            return req.response($0.data, as: .html)
        }
    }

    func connect(_ req: Request) throws -> Future<Response> {
        let userRequest = try req.content.decode(PublicUserRequest.self)

        return userRequest.flatMap(to: User.self) { request in
            let api = try req.make(APIInterface.self)
            return api.connexion(userRequest: request)
        }.map {
            try req.authenticate($0)
        }.transform(to: req.redirect(to: "home"))
    }

    func myMeetings(_ req: Request) throws -> Future<Response> {
        guard let user = try req.authenticated(User.self) else {
            return req.future(req.redirect(to: "/"))
        }
        let api = try req.make(APIInterface.self)
        return api.myTalks(token: user.token).flatMap { talks in
            return try req.view().render("myMeetings", HomeView(meetingsView: MeetingsView(talks: talks), createTalkOptions: CreateTalkView(isAdmin: , presenters: )))
        }.map { view in
            return req.response(view.data, as: .html)
        }
    }
}

struct MeetingView: Encodable {
    let talks: [PublicTalk]
    let date: String
}

struct MeetingsView: Encodable {
    let meetings: [MeetingView]

    init(talks: [PublicTalk]) {
        let allTalks = [String: [PublicTalk]](grouping: talks, by: { $0.presentationDate })

        self.meetings = allTalks.map { date, talks in MeetingView(talks: talks, date: date)}
    }
}

struct HomeView: Encodable {
    let meetingsView: MeetingsView
    let createTalkOptions: CreateTalkView
}

struct CreateTalkView: Encodable {
    let isAdmin: Bool
    let presenters: [String]
}

// Besoin de quoi ?
// 1. Page de connexion
// 2. Ajouter un talk ( + édition)
// 3. Liste de ses meetings (support édition / suppression)
// 4. Liste des meetings par date
