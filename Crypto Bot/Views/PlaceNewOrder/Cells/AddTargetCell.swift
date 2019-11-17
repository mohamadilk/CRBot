//
//  AddTargetCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol AddTargetCellDelegate {
    
    func targetAddedWith(price: String, cellIndex: Int)
}

class AddTargetCell: BaseTableViewCell {
    
    var addTargetDelegate: AddTargetCellDelegate?
    
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
    
    @IBOutlet weak var addTargetButton: UIButton! {
        didSet {
            self.addTargetButton.clipsToBounds = true
            self.addTargetButton.layer.cornerRadius = 5
            self.addTargetButton.backgroundColor = UIColor.binanceGreenColor()
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
    
    @IBAction func didPressAdd(_ sender: UIButton) {
        if let price = priceTextfield.text, price.count > 0 {
            addTargetDelegate?.targetAddedWith(price: price, cellIndex: index)
        }
    }
    
    override func set(value: String, index: Int) {
        if index == self.index {
            self.priceTextfield.text = value
        }
    }
}

extension AddTargetCell: UITextFieldDelegate {
    
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

extension AddTargetCell: StepperViewDelegate {
    func increaseButtonPressed() {
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
    
    func decreaseButtonPressed() {
        guard let symbol = symbol.symbol else { return }
        
        StepsUtility.shared.priceStepsFor(symbol: symbol) { (stepSize, error) in
            if error != nil || stepSize == nil {
                return
            }
            
            let currentPrice = self.priceTextfield.text
            if self.priceTextfield.text == nil || self.priceTextfield.text == "" || currentPrice!.doubleValue < stepSize!{
                return
            }
            
            NumbersUtilities.shared.formatted(price: (currentPrice!.doubleValue - stepSize!).toString(), for: symbol) { (price, error) in
                
                if error != nil || price == nil {
                    return
                }
                self.priceTextfield.text = price
                self.delegate?.textfieldValueChanged(index: self.index, text: self.priceTextfield.text ?? "0")
            }
        }
    }
}
