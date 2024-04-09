//
//  CacheRepository.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RxSwift

struct CacheRepository: ExchangeRepository {
    private let localRepository: ExchangeRepository
    private let remoteRepository: ExchangeRepository
    private let dateProvider: DateProviderType
    private let cacheHelper: CacheHelperType
    
    //Hardcoded time to enable refresh, 30 minutes
    private static let RefreshTimeInMinutes: Int = 30
    
    init(localRepository: ExchangeRepository = LocalRepository(),
         remoteRepository: ExchangeRepository = RemoteRepository(),
         dateProvider: DateProviderType = DateProvider(),
         cacheHelper: CacheHelperType = CacheHelper()) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
        self.dateProvider = dateProvider
        self.cacheHelper = cacheHelper
    }
    
    func fetch<T: Codable>() -> Observable<T> {
        let observable: Observable<T> = localRepository.fetch()
        return observable.flatMap { value -> Observable<T> in
            guard let cacheable = value as? Cacheable else {
                fatalError("Model must conform to Cacheable")
            }
            if self.isCacheExpired(cacheable) {
                return self.handleRemoteUpdate()
                    .catch { _ in
                        //If for some reason we cannot fetch remote data, we display latest data from local
                        observable
                    }
            }
            return Observable.just(value)
        }
        .catch { _ in
            self.handleRemoteUpdate()
        }
    }
}

private extension CacheRepository {
    func handleRemoteUpdate<T: Codable>() -> Observable<T> {
        remoteRepository.fetch()
            .observe(on: MainScheduler.instance)
            .do(onNext: { self.localRepository.update($0) })
    }
    
    func isCacheExpired(_ cacheable: Cacheable) -> Bool {
        cacheHelper.isCacheExpired(lastUpdated: cacheable.lastUpdated,
                                   currentDate: dateProvider.currentDate,
                                   refreshTimeInMinutes: CacheRepository.RefreshTimeInMinutes)
    }
}
