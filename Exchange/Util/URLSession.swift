//
//  URLSession.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 19/01/24.
//

import RxSwift

protocol URLSessionProtocol {
    func rx_data(request: URLRequest) -> Observable<Data>
}

extension URLSession: URLSessionProtocol {
    func rx_data(request: URLRequest) -> Observable<Data> {
        return rx.data(request: request)
    }
}
