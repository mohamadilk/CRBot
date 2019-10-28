//
//  AddTargetCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol AddTargetCellDelegate {
    
    func increasedValueFor(index: Int)
    func decreasedValueFor(index: Int)
    func textfieldValueChanged(index: Int, text: String)
    func targetAddedWith(price: String)
}

class AddTargetCell: UITableViewCell {

    var index: Int!
    var delegate: AddTargetCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceTextfield: UITextField! {
        didSet {
            self.priceTextfield.tag = index
            self.priceTextfield.delegate = self
            self.priceTextfield.keyboardType = .decimalPad
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
    
    @IBOutlet weak var addTargetButton: UIButton! {
        didSet {
            self.addTargetButton.clipsToBounds = true
            self.addTargetButton.layer.cornerRadius = 5
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
    
    @IBAction func didPressIncreaseButton(_ sender: UIButton) {
        delegate?.increasedValueFor(index: sender.tag)
        
    }
    
    @IBAction func didPressDecreaseButton(_ sender: UIButton) {
        delegate?.decreasedValueFor(index: sender.tag)
    }
    @IBAction func didPressAdd(_ sender: UIButton) {
        delegate?.targetAddedWith(price: priceTextfield.text ?? "")
    }
}

extension AddTargetCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textfieldValueChanged(index: index, text: textField.text ?? "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}