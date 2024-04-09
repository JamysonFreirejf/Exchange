//
//  MockAPIClient.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import Foundation

@testable import Exchange

final class MockAPIClient: APIClientType {
    func buildRequest(_ router: Exchange.APIRouter) -> URLRequest {
        URLRequest(url: URL(string: router.path)!)
    }
}
