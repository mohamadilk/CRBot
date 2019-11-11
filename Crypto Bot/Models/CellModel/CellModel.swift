//
//  CellModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/13/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class CellModel {
    
    var priceType: PriceCellTypes?
    var value: String?
    var cellType: CellType
    var title: String?
    var index: Int
    var isValid = false
    var targetsArray: [String]?
    
    init(priceType: PriceCellTypes? = nil, value: String? = nil, cellType: CellType, title: String? = nil, index: Int, targetsArray: [String]? = nil) {
        self.priceType = priceType
        self.value = value
        self.cellType = cellType
        self.title = title
        self.index = index
        self.targetsArray = targetsArray
    }
}
