//
//  MockCacheRepository.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import RxSwift
import RealmSwift

@testable import Exchange

final class MockRepository: ExchangeRepository {
    var lastUpdated: Date
    var forceError = false
    
    init(lastUpdated: Date) {
        self.lastUpdated = lastUpdated
    }
    
    func fetch<T: Codable>() -> Observable<T> {
        if forceError { return .error(MockExchangeRepositoryError.forced) }
        
        let stubsDecoder = StubsDecoder()
        guard let latest = stubsDecoder.decode(Latest.self, resource: "latest"),
                let currencies = stubsDecoder.decode(Map<String, String>.self, resource: "currencies"),
              let value = ExchangeRates(latest: latest,
                                        currencies: currencies,
                                        lastUpdated: lastUpdated) as? T else {
            return .never()
        }
        return .just(value)
    }
}
