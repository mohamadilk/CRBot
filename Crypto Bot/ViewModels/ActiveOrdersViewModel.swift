//
//  ActiveOrdersViewModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/21/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
import SugarRecord
import CoreData

class ActiveOrdersViewModel: NSObject {
    
    private var viewController: ActiveOrdersViewController!
    var acountHandler = AccountHandler.shared
    
    var ordersArray = [OrderDetailObject]()
    var queuedOrdersArray = [QueuedOrderObject]()
    
    init(viewController: ActiveOrdersViewController) {
        super.init()
        self.viewController = viewController
    }
    
    func getUserActiveOrders() {
        ExchangeHandler.shared.getAllAvailableSymbols { [weak self] (symbols, error) in
            self?.acountHandler.getUserActiveOrders { (activeOrders, error) in
                guard error == nil, activeOrders != nil else { return }
                self?.ordersArray = activeOrders!
                self?.viewController.reloadData()
            }
        }
    }
    
    func getUserQueuedOrders() {
        queuedOrdersArray = OrderHandler.shared.loadAllQueuedOrders() ?? []
    }
    
    func deleteQueuedOrder(model: QueuedOrderObject) {
        if OrderHandler.shared.deleteQueuedOrder(object: model) {
            getUserQueuedOrders()
            viewController.reloadData()
        }
    }
}
