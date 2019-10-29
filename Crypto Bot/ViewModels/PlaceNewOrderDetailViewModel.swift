//
//  PlaceNewOrderDetailViewModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class PlaceNewOrderDetailViewModel: NSObject {
    
    private var viewController: PlaceNewOrderDetailViewController!

    init(viewController: PlaceNewOrderDetailViewController) {
        super.init()
        self.viewController = viewController
    }
    
    func prepareDataSource(orderType: OrderTypes, orderSide: OrderSide) {
        
    }
}
