//
//  TargetCollectionViewCell.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol TargetCollectionViewCellDelegate {
    func didRemove(target: String)
}

class TargetCollectionViewCell: UICollectionViewCell {

    var delegate: TargetCollectionViewCellDelegate?
    
    var containerView: UIView?
    var clearButton: UIButton?
    var priceLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (containerView == nil) {
            containerView = UIView(frame: CGRect(x: 0, y: 10, width: 115, height: 30))
            containerView?.backgroundColor = .lightGray
            containerView?.clipsToBounds = true
            containerView?.layer.cornerRadius = 15
            
            self.contentView.addSubview(containerView!)
            
            priceLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 85, height: 30))
            priceLabel?.backgroundColor = .clear
            priceLabel?.clipsToBounds = true
            priceLabel?.font = UIFont.systemFont(ofSize: 12)
            priceLabel?.textColor = .darkGray
            priceLabel?.textAlignment = .center
            
            self.contentView.addSubview(priceLabel!)
            
            clearButton = UIButton(frame: CGRect(x: 85, y: 10, width: 30, height: 30))
            clearButton?.backgroundColor = .clear
            clearButton?.clipsToBounds = true
            clearButton?.setImage(UIImage(named: "clearButton"), for: .normal)
            clearButton?.addTarget(self, action: #selector(didPressClearButton), for: .touchUpInside)
            
            self.contentView.addSubview(clearButton!)
        }

    }

    @objc func didPressClearButton() {
        delegate?.didRemove(target: priceLabel?.text ?? "")
    }
}
