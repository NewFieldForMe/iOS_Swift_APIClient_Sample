//
//  APIRequest.swift
//  APIRequestSample
//
//  Created by yamada.ryo on 2020/06/15.
//  Copyright © 2020 yamada.ryo. All rights reserved.
//

import Foundation

struct APIRequest {
    let url: String
    let HTTPHeader: [String: String]
    let body: Data?
    let method: HTTPMethod
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
