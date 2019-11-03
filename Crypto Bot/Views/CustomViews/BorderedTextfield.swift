//
//  BorderedTextfield.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/11/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit

class BorderedTextfield: UITextField {

    var isValid = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 3
        self.layer.borderColor = UIColor.textfieldBorderColor().cgColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = .clear
    }
    
    func showValidState() {
        self.layer.borderColor = UIColor.binanceGreenColor().cgColor
        isValid = true
    }
    
    func showInvalidState() {
        self.layer.borderColor = UIColor.textfieldBorderColor().cgColor
        isValid = false
    }
    
    func showWarningState() {
        self.layer.borderColor = UIColor.binanceYellowColor().cgColor
        isValid = true
    }

}
