//
//  QueuedOrderTableViewCell.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/25/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol QueuedOrderTableViewCellDelegate {
    
    func didCancelOrder(model: QueuedOrderObject)
}

class QueuedOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.tintColor = UIColor.binanceYellowColor()
            self.cancelButton.layer.borderColor = UIColor.binanceYellowColor().cgColor
            self.cancelButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var delegate: QueuedOrderTableViewCellDelegate?
    var model: QueuedOrderObject!


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWith(model: QueuedOrderObject) {
        self.model = model
        symbolLabel.text = "\(model.asset) / \(model.currency)"
        limitLabel.text = model.stopLimitPrice
        targetLabel.text = model.price
        conditionLabel.text = " =< \(model.stopPrice)"
        NumbersUtilities.shared.formatted(quantity: model.amount, for: "\(model.asset)\(model.currency)") { [weak self] (amount, error) in
            self?.amountLabel.text = amount
        }

    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        delegate?.didCancelOrder(model: model)
    }
}
