//
//  AmountCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol AmountCellDelegate {
    
    func increasedValueFor(index: Int)
    func decreasedValueFor(index: Int)
    func textfieldValueChanged(index: Int, text: String)
    func amountChangedTo(percent: Int)
}

class AmountCell: UITableViewCell {

    var index: Int!
    var delegate: AmountCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var amountTextfield: UITextField!{
        didSet {
            self.amountTextfield.tag = index
            self.amountTextfield.delegate = self
            self.amountTextfield.keyboardType = .decimalPad
        }
    }
        
    @IBOutlet weak var stepperView: UIView! {
        didSet {
            self.stepperView.layer.cornerRadius = 5
            self.stepperView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var decreaseButton: UIButton! {
        didSet {
            self.decreaseButton.tag = index
            self.decreaseButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var increaseButton: UIButton! {
        didSet {
            self.increaseButton.tag = index
            self.increaseButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var twentyFivePercentButton: UIButton! {
        didSet {
            self.twentyFivePercentButton.clipsToBounds = true
            self.twentyFivePercentButton.layer.cornerRadius = 5
            self.twentyFivePercentButton.layer.borderColor = UIColor.darkGray.cgColor
            self.twentyFivePercentButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var fiftyPercentButton: UIButton! {
        didSet {
            self.twentyFivePercentButton.clipsToBounds = true
            self.twentyFivePercentButton.layer.cornerRadius = 5
            self.twentyFivePercentButton.layer.borderColor = UIColor.darkGray.cgColor
            self.twentyFivePercentButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var seventyFivePercentButton: UIButton! {
        didSet {
            self.twentyFivePercentButton.clipsToBounds = true
            self.twentyFivePercentButton.layer.cornerRadius = 5
            self.twentyFivePercentButton.layer.borderColor = UIColor.darkGray.cgColor
            self.twentyFivePercentButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var oneHundredPercentButton: UIButton! {
        didSet {
            self.twentyFivePercentButton.clipsToBounds = true
            self.twentyFivePercentButton.layer.cornerRadius = 5
            self.twentyFivePercentButton.layer.borderColor = UIColor.darkGray.cgColor
            self.twentyFivePercentButton.layer.borderWidth = 1
        }
    }
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didPressIncreaseButton(_ sender: UIButton) {
        delegate?.increasedValueFor(index: sender.tag)
        
    }
    
    @IBAction func didPressDecreaseButton(_ sender: UIButton) {
        delegate?.decreasedValueFor(index: sender.tag)
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
        delegate?.textfieldValueChanged(index: index, text: textField.text ?? "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
