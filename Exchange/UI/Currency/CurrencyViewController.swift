//
//  CurrencyViewController.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrencyViewController: UIViewController {
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var currenciesPickerView: UIPickerView!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var parentView: UIView!
    
    var viewModel: CurrencyViewModelType?
    private(set) var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBindings()
        setUpListeners()
    }
}

private extension CurrencyViewController {
    func setUpBindings() {
        viewModel?.currencies
            .drive(currenciesPickerView.rx.itemTitles) { _, item in
                item.description
            }
            .disposed(by: disposeBag)
        viewModel?.bindSelectedCurrency(observable: currenciesPickerView.rx.modelSelected(CurrencyItem.self).asObservable())
            .disposed(by: disposeBag)
        viewModel?.bindConfirm(observable: confirmButton.rx.tap.asObservable())
            .disposed(by: disposeBag)
    }
    
    func setUpListeners() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        viewModel?.confirm
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
