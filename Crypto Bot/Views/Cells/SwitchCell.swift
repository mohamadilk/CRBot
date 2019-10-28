//
//  SwitchCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate {
    
    func autoSellSwitchValueChanged(isEnable: Bool)
}

class SwitchCell: UITableViewCell {

    var delegate: SwitchCellDelegate?
    
    @IBOutlet weak var sellSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        delegate?.autoSellSwitchValueChanged(isEnable: sender.isOn)
    }
}
