//
//  APIClient.swift
//  APIRequestSample
//
//  Created by yamada.ryo on 2020/06/15.
//  Copyright © 2020 yamada.ryo. All rights reserved.
//

import Foundation

class APIClient {
    func request<T: Requestable>(_ requestable: T, completion: @escaping(T.Model?) -> Void) {
        guard let request = requestable.urlRequest else { return }
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                let model = try? requestable.decode(from: data)
                completion(model)
            }
        })
        task.resume()
    }
}

protocol Requestable {
    associatedtype Model: Codable

    var url: String { get }
    var httpMethod: String { get }
    var headers: [String: String] { get }
    func decode(from data: Data) throws -> Model
}

extension Requestable {
    var urlRequest: URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

struct GitHubAccountAPIRequest: Requestable {
    typealias Model = GitHubAccount

    var url: String {
        return "https://api.github.com/users/NewFieldForMe"
    }

    var httpMethod: String {
        return "GET"
    }

    var headers: [String : String] {
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

struct GitHubSearchRepositoriesAPIRequest: Requestable {
    typealias Model = GitHubRepositories

    var url: String {
        return "https://api.github.com/search/repositories?q=swift+api"
    }

    var httpMethod: String {
        return "GET"
    }

    var headers: [String : String] {
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
