//
//  APIClient.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import Foundation

protocol APIClientType {
    func buildRequest(_ router: APIRouter) -> URLRequest
}

struct APIClient: APIClientType {
    func buildRequest(_ router: APIRouter) -> URLRequest {
        guard let config = Bundle.main.decode(Config.self, resource: "Config") else {
            fatalError("Configuration file not provided")
        }
        guard let url = URL(string: config.baseURL.appending(router.path)) else {
            fatalError("Wrong url provided")
        }
        var request = URLRequest(url: url)
        request.httpMethod = router.method.rawValue
        request.addValue("Token \(config.accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
