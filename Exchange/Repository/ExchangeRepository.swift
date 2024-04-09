//
//  ExchangeRepository.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RxSwift

protocol ExchangeRepository {
    func fetch<T: Codable>() -> Observable<T>
    func update(_ T: Codable)
}

extension ExchangeRepository {
    func update(_ T: Codable) {}
}
