//
//  APIInterface.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

final class APIInterface {
    let client: Client
    let baseUrl: URL

    private func url(_ paths: String...) -> URL {
        var url = baseUrl
        for path in paths {
            url.appendPathComponent(path)
        }
        return url
    }

    init(client: Client, baseUrl: URL) {
        self.client = client
        self.baseUrl = baseUrl
    }

    func meetings() -> Future<[PublicMeeting]> {
        let url = self.url("meeting", "all")
        return client.get(url).flatMap { try $0.content.decode([PublicMeeting].self) }
    }

    func connexion(userRequest: PublicUserRequest) -> Future<User> {
        let tokenUrl = self.url("user", "token")
        let client = self.client
        let strongSelf = self
        return client.post(tokenUrl, headers: ["Authorization": userRequest.basicAuth]).flatMap {
            if $0.http.status == .ok {
                return try $0.content.decode(User.self)
            } else {
                return strongSelf.signin(userRequest: userRequest).flatMap {
                    client.post(tokenUrl, headers: ["Authorization": userRequest.basicAuth])
                }.flatMap {
                    return try $0.content.decode(User.self)
                }
            }
        }
    }

    func signin(userRequest: PublicUserRequest) -> Future<Void> {
        let userUrl = self.url("user")
        return client.post(userUrl, headers: ["Content-Type": "application/json"], beforeSend: { request in
            try request.content.encode(userRequest)
        }).map {
            guard $0.http.status == .ok else { throw VaporError(identifier: "", reason: "") }

            return ()
        }
    }
}

extension APIInterface: ServiceType {
    enum Error: Debuggable {
        case apiVariablesNeeded
        case noUrl

        var identifier: String {
            return "apiInterface.\(self)"
        }

        var reason: String {
            switch self {
            case .apiVariablesNeeded:
                return "the environment variables for api hostname and port isn't set. please provide these informations"
            case .noUrl:
                return "couldn't create url with hostname and port provided"
            }
        }
    }

    static func makeService(for container: Container) throws -> APIInterface {
        let client = try container.client()
        guard let hostname = Environment.get("api_hostname"),
            let port = Environment.get("api_port") else {
            throw Error.apiVariablesNeeded
        }

        guard let url = URL(string: "\(hostname):\(port)") else {
            throw Error.noUrl
        }
        return APIInterface(client: client, baseUrl: url)
    }
}
