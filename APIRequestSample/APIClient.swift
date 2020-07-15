//
//  APIClient.swift
//  APIRequestSample
//
//  Created by yamada.ryo on 2020/06/15.
//  Copyright © 2020 yamada.ryo. All rights reserved.
//

import Foundation

class APIClient {
    func request<T: Requestable>(_ requestable: T, completion: @escaping(Result<T.Model?, APIError>) -> Void) {
        guard var request = requestable.urlRequest() else { return }
        let gist = PostGist(public: false, fileName: "test", content: "yattane.")
        request.httpBody = try! JSONEncoder().encode(gist)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completion(.failure(APIError.unknown(error)))
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(APIError.noResponse))
                return
            }

            if case 200..<300 = response.statusCode {
                do {
                    let model = try requestable.decode(from: data)
                    completion(.success(model))
                } catch let decodeError {
                    completion(.failure(APIError.decode(decodeError)))
                }
            } else {
                completion(.failure(APIError.server(response.statusCode)))
            }
        })
        task.resume()
    }
}

enum APIError: Error {
    case server(Int)
    case decode(Error)
    case noResponse
    case unknown(Error)
}

protocol Requestable {
    associatedtype Model

    var url: String { get }
    var httpMethod: String { get }
    var headers: [String: String] { get }
    func decode(from data: Data) throws -> Model
    func urlRequest() -> URLRequest?
}

class Request: Requestable {
    typealias Model = Void
    var url: String {
        return ""
    }

    var httpMethod: String {
        return "GET"
    }

    var headers: [String : String] {
        return [:]
    }

    func encode<T: Encodable>(from model: T) -> Data? {
        return try! JSONEncoder().encode(model)
    }

    func decode(from data: Data) throws -> Void {
        return
    }

    func urlRequest() -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

class GitHubAccountAPIRequest: Request {
    typealias Model = GitHubAccount

    override var url: String {
        return "https://api.github.com/users/NewFieldForMe"
    }

    override var httpMethod: String {
        return "GET"
    }

    override var headers: [String : String] {
        return [:]
    }

    func decode(from data: Data) throws -> GitHubAccount {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubAccount.self, from: data)
    }
}

struct GitHubAccount: Codable {
    let name: String
    let bio: String
}

class CreateGistAPIRequest: Request {
    typealias Model = Void

    var gist: PostGist?

    var body: Encodable? {
        return gist
    }

    var token = "7b4f7f5b4505b5da9866f39b7464cd6c73acd265"

    override var url: String {
        return "https://api.github.com/gists"
    }

    override var httpMethod: String {
        return "POST"
    }

    override var headers: [String: String] {
        return [
            "Content-type": "application/json; charset=utf-8",
            "Authorization": "token \(token)"
        ]
    }
}

struct PostGist {
    let `public`: Bool
    let fileName: String
    let content: String
}

extension PostGist: Codable {
    private struct CustomCodingKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) { return nil }

        static let `public` = CustomCodingKey(stringValue: "public")!
        static let files = CustomCodingKey(stringValue: "files")!
        static let content = CustomCodingKey(stringValue: "content")!
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKey.self)
        `public` = try container.decode(Bool.self, forKey: .public)
        let filesContainer = try container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .files)
        fileName = filesContainer.allKeys.first!.stringValue
        let fileContainer = try filesContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: CustomCodingKey(stringValue: fileName)!)
        content = try fileContainer.decode(String.self, forKey: .content)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKey.self)
        try container.encode(`public`, forKey: .public)
        var filesContainer = container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .files)
        let fileNameKey = CustomCodingKey(stringValue: fileName)!
        var fileContainer = filesContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: fileNameKey)
        try fileContainer.encode(content, forKey: .content)
    }
}

class GitHubSearchRepositoriesAPIRequest: Request {
    typealias Model = GitHubRepositories

    override var url: String {
        return "https://api.github.com/search/repositories?q=swift+api"
    }

    override var httpMethod: String {
        return "GET"
    }

    override var headers: [String : String] {
        return [:]
    }

    func decode(from data: Data) throws -> GitHubRepositories {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubRepositories.self, from: data)
    }
}

struct GitHubRepositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [GitHubRepository]?
}

struct GitHubRepository: Codable {
    let name: String
    let htmlUrl: String
}
