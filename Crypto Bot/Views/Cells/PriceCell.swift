//
//  PriceCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

enum PriceCellTypes {
    case buyPrice
    case sellPrice
    case total
    case buyStopPrice
    case buyLimitPrice
    case sellStopPrice
    case sellLimitPrice
}

protocol PriceCellDelegate {
    
    func increasedValueFor(index: Int)
    func decreasedValueFor(index: Int)
    func textfieldValueChanged(index: Int, text: String)
}

class PriceCell: BaseTableViewCell {

    var delegate: PriceCellDelegate?
    var priceType: PriceCellTypes!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceTextfield: UITextField! {
        didSet {
            self.priceTextfield.delegate = self
            self.priceTextfield.keyboardType = .decimalPad
            self.priceTextfield.layer.borderColor = UIColor.borderGrayColor().cgColor
        }
    }
    
    @IBOutlet weak var stepperView: StepperView! {
        didSet {
            self.stepperView.delegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PriceCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textfieldValueChanged(index: index, text: textField.text ?? "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension PriceCell: StepperViewDelegate {
    func increaseButtonPressed() {
        delegate?.increasedValueFor(index: index)
    }
    
    func decreaseButtonPressed() {
        delegate?.decreasedValueFor(index: index)
    }
}
