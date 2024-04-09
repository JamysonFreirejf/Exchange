//
//  MockLocalRepository.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import RxSwift

@testable import Exchange

enum MockExchangeRepositoryError: Error {
    case forced
}

final class MockLocalRepository: ExchangeRepository {
    var shouldForceError = false
    
    func fetch<T: Codable>() -> Observable<T> {
        if shouldForceError {
            return .error(MockExchangeRepositoryError.forced)
        }
        guard let value = MockItem(title: "Local Data") as? T else {
            return .never()
        }
        return .just(value)
    }
}
