//
//  APIInterface.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

final class APIInterface {
    let logger: Logger
    let baseUrl: URL

    let basicDateDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private func url(_ paths: String...) -> URL {
        var url = baseUrl
        for path in paths {
            url.appendPathComponent(path)
        }
        return url
    }

    init(logger: Logger, baseUrl: URL) {
        self.logger = logger
        self.baseUrl = baseUrl
    }

    func talks(client: Client) -> Future<[PublicTalk]> {
        let url = self.url("talk", "all")
        let decoder = self.basicDateDecoder
        return client.get(url).flatMap { try $0.content.decode([PublicTalk].self, using: decoder) }
    }

    func myTalks(client: Client, user: User) -> Future<[PublicTalk]> {
        let url = self.url("talk")
        let decoder = self.basicDateDecoder
        return client.get(url, headers: ["Authorization": user.bearerAuth]).flatMap { try $0.content.decode([PublicTalk].self, using: decoder) }
    }

    func usernames(client: Client) -> Future<[String]> {
        let url = self.url("users")
        return client.get(url)
            .flatMap { try $0.content.decode([PublicUser].self) }
            .map { $0.map { $0.username } }
    }

    func connexion(client: Client, userRequest: PublicUserRequest) -> Future<User> {
        let meUrl = self.url("user", "connect")
        let strongSelf = self
        return client.get(meUrl, headers: ["Authorization": userRequest.basicAuth]).flatMap { [weak self] response in
            switch response.http.status {
            case .ok:
                return try response.content.decode(User.self)
            case .unauthorized:
                throw Error.badPassword
            case .preconditionFailed:
                return strongSelf.signin(client: client, userRequest: userRequest).flatMap {
                    client.get(meUrl, headers: ["Authorization": userRequest.basicAuth])
                }.flatMap {
                    return try $0.content.decode(User.self)
                }
            default:
                self?.logger.error("this is an error to catch : \(response.debugDescription)")
                throw Error.genericError
            }
        }
    }

    func signin(client: Client, userRequest: PublicUserRequest) -> Future<Void> {
        let userUrl = self.url("user")
        return client.post(userUrl, headers: ["Content-Type": "application/json"], beforeSend: { request in
            try request.content.encode(userRequest)
        }).map { [weak self] response in
            guard response.http.status == .ok else {
                self?.logger.warning("User not created : \(response.debugDescription)")
                throw Error.couldntSignIn
            }

            return ()
        }
    }

    func createTalk(client: Client, talkRequest: PublicTalkRequest, user: User) -> Future<Void> {
        let url = self.url("talk")
        return client.post(
            url,
            headers: [
                "Content-Type": "application/json",
                "Authorization": user.bearerAuth
            ],
            beforeSend: { request in
                try request.content.encode(talkRequest)
            }
        ).map { [weak self] response in
            guard [.ok, .created].contains(response.http.status) else {
                self?.logger.warning("Talk not created : \(response.debugDescription)")
                throw Error.couldntCreateTalk
            }

            return ()
        }
    }
}

extension APIInterface: ServiceType {
    enum Error: String, Debuggable {
        case apiVariablesNeeded
        case noUrl
        case badPassword
        case genericError
        case couldntSignIn
        case couldntCreateTalk

        var identifier: String {
            return "apiInterface.\(self.rawValue)"
        }

        var reason: String {
            switch self {
            case .couldntCreateTalk:
                return "return status not ok for creating a talk"
            case .couldntSignIn:
                return "return status not ok for sign in"
            case .genericError:
                return "Sorry, the API couldn't respond. Try again..."
            case .badPassword:
                return "The username / password couple is not good"
            case .apiVariablesNeeded:
                return "the environment variables for api hostname and port isn't set. please provide these informations"
            case .noUrl:
                return "couldn't create url with hostname and port provided"
            }
        }
    }

    static func makeService(for container: Container) throws -> APIInterface {
        let logger = try container.make(Logger.self)
        guard let hostname = Environment.get("api_hostname"),
            let port = Environment.get("api_port") else {
            throw Error.apiVariablesNeeded
        }

        guard let url = URL(string: "\(hostname):\(port)") else {
            throw Error.noUrl
        }
        return APIInterface(logger: logger, baseUrl: url)
    }
}
