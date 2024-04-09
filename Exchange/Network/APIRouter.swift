//
//  APIRouter.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 19/01/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

enum APIRouter: String {
    case latest
    case currencies
    
    var path: String {
        switch self {
        case .latest:
            return "latest.json"
        case .currencies:
            return "currencies.json"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
}
