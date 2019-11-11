//
//  AmountCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

class AmountCell: BaseTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var amountTextfield: BorderedTextfield!{
        didSet {
            self.amountTextfield.delegate = self
            self.amountTextfield.keyboardType = .decimalPad
        }
    }
        
    @IBOutlet weak var stepperView: StepperView! {
        didSet {
            self.stepperView.delegate = self
        }
    }
    
    @IBOutlet weak var twentyFivePercentButton: UIButton! {
        didSet {
            self.twentyFivePercentButton.clipsToBounds = true
            self.twentyFivePercentButton.layer.cornerRadius = 5
            self.twentyFivePercentButton.layer.borderColor = UIColor.lightGray.cgColor
            self.twentyFivePercentButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var fiftyPercentButton: UIButton! {
        didSet {
            self.fiftyPercentButton.clipsToBounds = true
            self.fiftyPercentButton.layer.cornerRadius = 5
            self.fiftyPercentButton.layer.borderColor = UIColor.lightGray.cgColor
            self.fiftyPercentButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var seventyFivePercentButton: UIButton! {
        didSet {
            self.seventyFivePercentButton.clipsToBounds = true
            self.seventyFivePercentButton.layer.cornerRadius = 5
            self.seventyFivePercentButton.layer.borderColor = UIColor.lightGray.cgColor
            self.seventyFivePercentButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var oneHundredPercentButton: UIButton! {
        didSet {
            self.oneHundredPercentButton.clipsToBounds = true
            self.oneHundredPercentButton.layer.cornerRadius = 5
            self.oneHundredPercentButton.layer.borderColor = UIColor.lightGray.cgColor
            self.oneHundredPercentButton.layer.borderWidth = 1
        }
    }
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func set(value: String, index: Int) {
        if index == self.index {
            self.amountTextfield.text = value
        }
    }
    
    func updateValidity(state: ValidityState) {
        switch state {
        case .valid:
            self.amountTextfield.showValidState()
            break
        case .invalid:
            self.amountTextfield.showInvalidState()
            break
        case .warning:
            self.amountTextfield.showWarningState()
            break
        }
    }

    @IBAction func didPress25PercentButton(_ sender: UIButton) {
        delegate?.amountChangedTo(percent: 25)
    }
    
    @IBAction func didPress50PercentButton(_ sender: UIButton) {
        delegate?.amountChangedTo(percent: 50)
    }
    
    @IBAction func didPress75PercentButton(_ sender: UIButton) {
        delegate?.amountChangedTo(percent: 75)
    }
    
    @IBAction func didPress100PercentButton(_ sender: UIButton) {
        delegate?.amountChangedTo(percent: 100)
    }
    
}

extension AmountCell: UITextFieldDelegate {
    
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

extension AmountCell: StepperViewDelegate {
    func increaseButtonPressed() {
        guard let symbol = symbol.symbol else { return }

        StepsUtility.shared.quantutyStepsFor(symbol: symbol) { (stepSize, error) in
            if error != nil || stepSize == nil {
                return
            }
            
            let currentQty = (self.amountTextfield.text == nil || self.amountTextfield.text == "") ? stepSize!.toString() : (self.amountTextfield.text!.doubleValue + stepSize!).toString()
            
            NumbersUtilities.shared.formatted(quantity: currentQty, for: symbol) { (quantity, error) in
                               
                if error != nil || quantity == nil {
                    return
                }
                self.amountTextfield.text = quantity
                self.delegate?.textfieldValueChanged(index: self.index, text: self.amountTextfield.text ?? "0")
            }
        }
    }
    
    func decreaseButtonPressed() {
        guard let symbol = symbol.symbol else { return }

        StepsUtility.shared.quantutyStepsFor(symbol: symbol) { (stepSize, error) in
            if error != nil || stepSize == nil {
                return
            }
            
            let currentQty = self.amountTextfield.text
            if self.amountTextfield.text == nil || self.amountTextfield.text == "" || currentQty!.doubleValue < stepSize!{
                return
            }
            
            NumbersUtilities.shared.formatted(quantity: (currentQty!.doubleValue - stepSize!).toString(), for: symbol) { (quantity, error) in
                
                if error != nil || quantity == nil {
                    return
                }
                self.amountTextfield.text = quantity
                self.delegate?.textfieldValueChanged(index: self.index, text: self.amountTextfield.text ?? "0")
            }
        }
    }
}
