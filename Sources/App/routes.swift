import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // "It works" page
    router.get { req in
        return try req.view().render("welcome")
    }
    
    // Says hello
    router.get("hello", String.parameter) { req -> Future<View> in
        return try req.view().render("hello", [
            "name": req.parameters.next(String.self)
        ])
    }

    let controller = Controller()

    let authGroup = router.grouped(User.authSessionsMiddleware())

    router.get("meetings", use: controller.meetings)
    authGroup.get("connexion", use: controller.connexion)
    authGroup.post("connexion", use: controller.connect)
    authGroup.get("home", use: controller.meetings)
}

final class Controller {
    func meetings(_ req: Request) throws -> Future<View> {
        let api = try req.make(APIInterface.self)
        return api.meetings().flatMap { meetings in
            return try req.view().render("allMeetings", MeetingsView(meetings: meetings))
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
}

struct MeetingsView: Encodable {
    let meetings: [String: [PublicMeeting]]
    let dates: [String]

    init(meetings: [PublicMeeting]) {
        self.meetings = [String: [PublicMeeting]](grouping: meetings, by: { $0.presentationDate })
        self.dates = [String](self.meetings.keys)
    }
}

// Besoin de quoi ?
// 1. Page de connexion
// 2. Ajouter un meeting (édition)
// 3. Liste de ses meetings (support édition / suppression)
// 4. Liste des meetings par date
