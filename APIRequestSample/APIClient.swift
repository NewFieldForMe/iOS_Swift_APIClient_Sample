//
//  APIClient.swift
//  APIRequestSample
//
//  Created by yamada.ryo on 2020/06/15.
//  Copyright © 2020 yamada.ryo. All rights reserved.
//

import Foundation

class APIClient {
    func request() {
        guard let url = URL(string: "https://api.github.com/users/{user_name}") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            dump(data)
            dump(response)
            dump(error)
            if let data = data {
                let account = try? JSONDecoder().decode(GitHubAccount.self, from: data)
                dump(account)
            }
        })
        task.resume()
    }
}

struct GitHubAccount: Codable {
    let name: String
    let bio: String
}
