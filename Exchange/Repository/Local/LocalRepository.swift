//
//  LocalRepository.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RealmSwift
import RxSwift

enum LocalRepositoryError: Error {
    case noLocalData
}

struct LocalRepository: ExchangeRepository {
    private let realm: Realm
    
    init(realm: Realm = RealmHandler.shared.realm) {
        self.realm = realm
    }
    
    func fetch<T: Codable>() -> Observable<T> {
        Observable.create { observer in
            let exchangeRate = self.realm.objects(ExchangeRates.self).last
            
            if let value = exchangeRate as? T {
                observer.onNext(value)
            } else {
                observer.onError(LocalRepositoryError.noLocalData)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func update(_ T: Codable) {
        guard let exchangeRate = T as? ExchangeRates else {
            return
        }
        try? realm.write {
            self.realm.add(exchangeRate, update: .all)
        }
    }
}
