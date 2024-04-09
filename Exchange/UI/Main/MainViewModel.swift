//
//  MainViewModel.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RxSwift
import RxCocoa

protocol MainViewModelType {
    var results: Driver<[ResultItem]> { get }
    var showCurrenciesScreen: Driver<[CurrencyItem]> { get }
    var selectedCurrency: Driver<String> { get }
    var lastUpdated: Driver<String?> { get }
    var showLoading: Driver<Void> { get }
    var hideLoading: Driver<Void> { get }
    var errorDescription: Driver<String> { get }
    var isNoDataLayoutHidden: Driver<Bool> { get }
    
    func bindFetch() -> Disposable
    func bindInput(observable: Observable<String?>) -> Disposable
    func bindSelectedCurrency(observable: Observable<CurrencyItem?>) -> Disposable
    func bindShowCurrencies(observable: Observable<Void>) -> Disposable
    func retryFetch()
}

struct MainViewModel: MainViewModelType {
    private let repository: ExchangeRepository
    private let dateProvider: DateProviderType
    private let contentRelay: BehaviorRelay<ExchangeRates?>
    private let inputRelay: PublishRelay<String>
    private let selectedCurrencyRelay: BehaviorRelay<String>
    private let showCurrenciesRelay: PublishRelay<Void>
    private let showLoadingRelay: PublishRelay<Void>
    private let hideLoadingRelay: PublishRelay<Void>
    private let errorDescriptionRelay: PublishRelay<String>
    private let retryFetchRelay: PublishRelay<Void>
    
    private static let DefaultCurrency = "USD"
    
    init(repository: ExchangeRepository = CacheRepository(),
         dateProvider: DateProviderType = DateProvider()) {
        self.repository = repository
        self.dateProvider = dateProvider
        contentRelay = BehaviorRelay(value: nil)
        inputRelay = PublishRelay()
        selectedCurrencyRelay = BehaviorRelay(value: MainViewModel.DefaultCurrency)
        showCurrenciesRelay = PublishRelay()
        showLoadingRelay = PublishRelay()
        hideLoadingRelay = PublishRelay()
        errorDescriptionRelay = PublishRelay()
        retryFetchRelay = PublishRelay()
    }
    
    var results: Driver<[ResultItem]> {
        Observable.combineLatest(contentRelay.compactMap { $0 },
                                 transformInputToDouble(),
                                 selectedCurrencyRelay)
        .distinctUntilChanged { old, new in
            old.1 == new.1 && old.2 == new.2
        }
        .map { content, input, selectedCurrency in
            let rates = content.latest?.rates
            guard let valueForSelectedCurrency = rates?
                .filter({ $0.key == selectedCurrency })
                .first?.value, input > 0 else {
                return []
            }
            return rates?.map { entry in
                ResultItem(currency: entry.key,
                           value: (entry.value / valueForSelectedCurrency) * input)
            } ?? []
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    var showCurrenciesScreen: Driver<[CurrencyItem]> {
        showCurrenciesRelay
            .withLatestFrom(contentRelay)
            .compactMap { $0 }
            .map { $0.currencies }
            .map { currencies in
                currencies.map {
                    CurrencyItem(currency: $0.key, value: $0.value)
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    var selectedCurrency: Driver<String> {
        selectedCurrencyRelay.asDriver()
    }
    
    var lastUpdated: Driver<String?> {
        contentRelay
            .map { $0?.lastUpdated }
            .map { date in
                guard let date = date else {
                    return nil
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = dateProvider.timeZone
                return "Last Updated: \(dateFormatter.string(from: date))"
            }
            .asDriver(onErrorJustReturn: nil)
    }
    
    var showLoading: Driver<Void> {
        showLoadingRelay.asDriver(onErrorJustReturn: ())
    }
    
    var hideLoading: Driver<Void> {
        hideLoadingRelay.asDriver(onErrorJustReturn: ())
    }
    
    var errorDescription: Driver<String> {
        errorDescriptionRelay.asDriver(onErrorJustReturn: "")
    }
    
    var isNoDataLayoutHidden: Driver<Bool> {
        Observable.combineLatest(inputRelay.startWith(""), contentRelay.distinctUntilChanged())
            .map { input, content in
                input.isEmpty || content != nil
            }
            .asDriver(onErrorJustReturn: false)
    }
    
    func bindFetch() -> Disposable {
        Observable.combineLatest(selectedCurrencyRelay.distinctUntilChanged(),
                                 retryFetchRelay.startWith(()))
        .do(onNext: { _ in
            showLoadingRelay.accept(())
        })
        .flatMap { _ in
            let fetch: Observable<ExchangeRates> = repository.fetch()
            return fetch.materialize()
        }
        .subscribe(onNext: { event in
            switch event {
            case .next(let value):
                contentRelay.accept(value)
                hideLoadingRelay.accept(())
            case .error(let error):
                errorDescriptionRelay.accept(error.localizedDescription)
                hideLoadingRelay.accept(())
            default:
                hideLoadingRelay.accept(())
            }
        })
    }
    
    func bindInput(observable: Observable<String?>) -> Disposable {
        observable
            .compactMap { $0 }
            .bind(to: inputRelay)
    }
    
    func bindSelectedCurrency(observable: Observable<CurrencyItem?>) -> Disposable {
        observable
            .map { $0?.currency }
            .compactMap { $0 }
            .bind(to: selectedCurrencyRelay)
    }
    
    func bindShowCurrencies(observable: Observable<Void>) -> Disposable {
        observable.bind(to: showCurrenciesRelay)
    }
    
    func retryFetch() {
        retryFetchRelay.accept(())
    }
}

private extension MainViewModel {
    func transformInputToDouble() -> Observable<Double> {
        inputRelay
            .map { Double($0) ?? 0 }
    }
}
