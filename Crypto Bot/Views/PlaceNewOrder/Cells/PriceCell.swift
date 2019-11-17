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

class PriceCell: BaseTableViewCell {
    
    var priceType: PriceCellTypes!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceTextfield: BorderedTextfield! {
        didSet {
            self.priceTextfield.delegate = self
            self.priceTextfield.keyboardType = .decimalPad
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func set(value: String, index: Int) {
        if index == self.index {
            self.priceTextfield.text = value
        }
    }
    
    func updateValidity(state: ValidityState) {
        switch state {
        case .valid:
            self.priceTextfield.showValidState()
            break
        case .invalid:
            self.priceTextfield.showInvalidState()
            break
        case .warning:
            self.priceTextfield.showWarningState()
            break
        }
    }
    
}

extension PriceCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            delegate?.textfieldValueChanged(index: index, text: updatedText )
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}

extension PriceCell: StepperViewDelegate {
    func increaseButtonPressed() {
        if priceType == .total {
            increaseTotalValue()
        } else {
            increasePriceValue()
        }
    }
    
    func decreaseButtonPressed() {
        if priceType == .total {
            decreaseTotalValue()
        } else {
            decreasePriceValue()
        }
    }
    
    private func increaseTotalValue() {
        if priceTextfield.text == nil || priceTextfield.text == "" {
            priceTextfield.text = "1"
            delegate?.textfieldValueChanged(index: self.index, text: priceTextfield.text ?? "0")
        } else {
            guard let symbol = symbol.symbol else { return }
            
            let currentPrice = priceTextfield.text
            NumbersUtilities.shared.formatted(quantity: "\(currentPrice!.doubleValue + 1)", for: symbol) { (quantity, error) in
                self.priceTextfield.text = quantity
                self.delegate?.textfieldValueChanged(index: self.index, text: self.priceTextfield.text ?? "0")
            }
        }
    }
    
    private func decreaseTotalValue() {
        if priceTextfield.text == nil || priceTextfield.text == "" {
            return
        } else {
            guard let symbol = symbol.symbol else { return }
            
            let currentPrice = priceTextfield.text
            if currentPrice!.doubleValue > 1 {
                NumbersUtilities.shared.formatted(quantity: "\(currentPrice!.doubleValue - 1)", for: symbol) { (quantity, error) in
                    
                    if error != nil || quantity == nil {
                        return
                    }
                    self.priceTextfield.text = quantity
                    self.delegate?.textfieldValueChanged(index: self.index, text: self.priceTextfield.text ?? "0")
                }
            }
        }
    }
    
    private func increasePriceValue() {
        guard let symbol = symbol.symbol else { return }
        
        StepsUtility.shared.priceStepsFor(symbol: symbol) { (stepSize, error) in
            if error != nil || stepSize == nil {
                return
            }
            
            let currentPrice = (self.priceTextfield.text == nil || self.priceTextfield.text == "") ? stepSize!.toString() : (self.priceTextfield.text!.doubleValue + stepSize!).toString()
            
            NumbersUtilities.shared.formatted(price: currentPrice, for: symbol) { (price, error) in
                
                if error != nil || price == nil {
                    return
                }
                self.priceTextfield.text = price
                self.delegate?.textfieldValueChanged(index: self.index, text: self.priceTextfield.text ?? "0")
            }
        }
    }
    
    private func decreasePriceValue() {
        StepsUtility.shared.priceStepsFor(symbol: symbol.symbol!) { (stepSize, error) in
            if error != nil || stepSize == nil {
                return
            }
            
            let currentPrice = self.priceTextfield.text
            if self.priceTextfield.text == nil || self.priceTextfield.text == "" || currentPrice!.doubleValue < stepSize!{
                return
            }
            
            NumbersUtilities.shared.formatted(price: (currentPrice!.doubleValue - stepSize!).toString(), for: self.symbol.symbol!) { (price, error) in
                
                if error != nil || price == nil {
                    return
                }
                self.priceTextfield.text = price
                self.delegate?.textfieldValueChanged(index: self.index, text: self.priceTextfield.text ?? "0")
            }
        }
    }
}

extension Double {
    
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        let string = String(format: "%.\(value)f", self)
        return string
    }
}
