//
//  StepperView.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol StepperViewDelegate {
    
    func increaseButtonPressed()
    func decreaseButtonPressed()
}

class StepperView: UIView {

    public var delegate: StepperViewDelegate?

    private var increaseButton: UIButton!
    private var decreaseButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
    
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.borderGrayColor()
        self.layer.borderColor = UIColor.borderGrayColor().cgColor
        self.layer.borderWidth = 1
        
        decreaseButton = UIButton(frame: CGRect(x: 0, y: 0, width: CGFloat(Int(self.frame.size.width / 2)), height: self.frame.size.height))
        decreaseButton.backgroundColor = .white
        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        decreaseButton.setTitle("-", for: .normal)
        decreaseButton.setTitleColor(UIColor.borderGrayColor(), for: .normal)
        
        self.addSubview(decreaseButton)
        
        increaseButton = UIButton(frame: CGRect(x: CGFloat(Int(self.frame.size.width / 2) + 1), y: 0, width: CGFloat(Int(self.frame.size.width / 2)), height: self.frame.size.height))
        increaseButton.backgroundColor = .white
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        increaseButton.setTitle("+", for: .normal)
        increaseButton.setTitleColor(UIColor.borderGrayColor(), for: .normal)
        
        self.addSubview(increaseButton)
    }

    @objc func increaseTapped() {
        delegate?.increaseButtonPressed()
    }

    @objc func decreaseTapped() {
        delegate?.decreaseButtonPressed()
    }
}
