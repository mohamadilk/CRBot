//
//  TargetCollectionViewCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol TargetCollectionViewCellDelegate {
    func didRemove(target: String)
}

class TargetCollectionViewCell: UICollectionViewCell {

    var delegate: TargetCollectionViewCellDelegate?
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = 14
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBAction func didPressClearButton(_ sender: UIButton) {
        delegate?.didRemove(target: priceLabel.text ?? "")
    }
}
