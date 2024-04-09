//
//  MockURLSession.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import RxSwift

@testable import Exchange

enum MockURLSessionError: Error {
    case noData
    case invalidPath
    case forcedError
}

final class MockURLSession: URLSessionProtocol {
    var forceError = false
    
    private func getData(_ router: APIRouter) -> Data? {
        let bundle = Bundle(for: type(of: self))
        return bundle.data(Data.self, resource: router.rawValue)
    }
    
    func rx_data(request: URLRequest) -> Observable<Data> {
        if forceError { return .error(MockURLSessionError.forcedError) }
        
        let path = request.url?.pathComponents.last
        if path == APIRouter.latest.path {
            if let data = getData(.latest) {
                return .just(data)
            }
            return .error(MockURLSessionError.noData)
        }
        if path == APIRouter.currencies.path {
            if let data = getData(.currencies) {
                return .just(data)
            }
            return .error(MockURLSessionError.noData)
        }
        return .error(MockURLSessionError.invalidPath)
    }
}

