//
//  AddTargetCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol AddTargetCellDelegate {
    
//    func increasedValueFor(index: Int)
//    func decreasedValueFor(index: Int)
//    func textfieldValueChanged(index: Int, text: String)
    func targetAddedWith(price: String, cellIndex: Int)
}

class AddTargetCell: BaseTableViewCell {

    var delegate: AddTargetCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceTextfield: UITextField! {
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

    @IBAction func didPressAdd(_ sender: UIButton) {
        if let price = priceTextfield.text, price.count > 0 {
            delegate?.targetAddedWith(price: price, cellIndex: index)
        }
    }
}

extension AddTargetCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        delegate?.textfieldValueChanged(index: index, text: textField.text ?? "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension AddTargetCell: StepperViewDelegate {
    func increaseButtonPressed() {
//        delegate?.increasedValueFor(index: index)
    }
    
    func decreaseButtonPressed() {
//        delegate?.decreasedValueFor(index: index)
    }
}
