//
//  RemoteRepository.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RxSwift
import RxCocoa
import RealmSwift

enum RemoteRepositoryError: Error {
    case requestFailed
}

struct RemoteRepository: ExchangeRepository {
    private let apiClient: APIClientType
    private let urlSession: URLSessionProtocol
    
    init(apiClient: APIClientType = APIClient(),
         urlSession: URLSessionProtocol = URLSession.shared) {
        self.apiClient = apiClient
        self.urlSession = urlSession
    }
    
    func fetch<T: Codable>() -> Observable<T> {
        let latest: Observable<Latest> = fetch(.latest)
        let currencies: Observable<Map<String, String>> = fetch(.currencies)
        return Observable.zip(latest, currencies)
            .map { latest, currencies in
                ExchangeRates(latest: latest,
                              currencies: currencies) as? T
            }
            .compactMap { $0 }
    }
}

private extension RemoteRepository {
    func fetch<T: Codable>(_ router: APIRouter) -> Observable<T> {
        urlSession.rx_data(request: apiClient.buildRequest(router))
            .map { data in
                let json = try JSONDecoder().decode(T.self, from: data)
                return json
            }
            .catch { error in
                //Stream down spcefic errors like network errors etc
                return .error(error)
            }
    }
}
