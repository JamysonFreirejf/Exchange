//
//  ResultViewCell.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import UIKit

final class ResultViewCell: UICollectionViewCell {
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    func setUpView(resultItem: ResultItem) {
        currencyLabel.text = resultItem.currency
        valueLabel.text = String(resultItem.value)
    }
}
