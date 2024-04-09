//
//  CurrencyViewModel.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import RxSwift
import RxCocoa

struct CurrencyItem {
    let currency: String
    let value: String
    
    var description: String {
        "\(currency) - \(value)"
    }
}

protocol CurrencyViewModelType {
    var confirm: Driver<Void> { get }
    var currencies: Driver<[CurrencyItem]> { get }
    var selectedCurrency: Driver<CurrencyItem?> { get }
    
    func bindSelectedCurrency(observable: Observable<[CurrencyItem]>) -> Disposable
    func bindConfirm(observable: Observable<Void>) -> Disposable
}

struct CurrencyViewModel: CurrencyViewModelType {
    private let currenciesRelay: BehaviorRelay<[CurrencyItem]>
    private let selectedCurrencyRelay: PublishRelay<CurrencyItem?>
    private let confirmRelay: PublishRelay<Void>
    
    init(currencies: [CurrencyItem]) {
        currenciesRelay = BehaviorRelay(value: currencies)
        selectedCurrencyRelay = PublishRelay()
        confirmRelay = PublishRelay()
    }
    
    var confirm: Driver<Void> {
        confirmRelay.asDriver(onErrorJustReturn: ())
    }
    
    var currencies: Driver<[CurrencyItem]> {
        currenciesRelay.asDriver(onErrorJustReturn: [])
    }
    
    var selectedCurrency: Driver<CurrencyItem?> {
       confirmRelay
            .withLatestFrom(selectedCurrencyRelay.startWith(currenciesRelay.value.first))
            .distinctUntilChanged { old, new in
                old?.currency == new?.currency
            }
            .asDriver(onErrorJustReturn: nil)
    }
    
    func bindSelectedCurrency(observable: Observable<[CurrencyItem]>) -> Disposable {
        observable
            .map { $0.last }
            .compactMap { $0 }
            .bind(to: selectedCurrencyRelay)
    }
    
    func bindConfirm(observable: Observable<Void>) -> Disposable {
        observable.bind(to: confirmRelay)
    }
}
