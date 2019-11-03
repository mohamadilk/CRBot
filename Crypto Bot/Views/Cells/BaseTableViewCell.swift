//
//  BaseTableViewCell.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit

enum CellType {
    case CellType_price
    case CellType_amount
    case CellType_description
    case CellType_switch
    case CellType_addTarget
    case CellType_targets
}

protocol BaseTableViewCellDelegate {

    func textfieldValueChanged(index: Int, text: String)
    func amountChangedTo(percent: Int)
}

class BaseTableViewCell: UITableViewCell {

    var delegate: BaseTableViewCellDelegate?

    var symbol: SymbolObject!
    var cellType: CellType!
    var index: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(value: String, index: Int) {}
}
