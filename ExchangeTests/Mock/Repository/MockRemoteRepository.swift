//
//  MockRemoteRepository.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import RxSwift

@testable import Exchange

struct MockRemoteRepository: ExchangeRepository {
    func fetch<T: Codable>() -> Observable<T> {
        guard let value = MockItem(title: "Remote Data") as? T else {
            return .never()
        }
        return .just(value)
    }
}
