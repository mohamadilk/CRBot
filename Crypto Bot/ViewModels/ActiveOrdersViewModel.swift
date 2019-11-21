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
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserOrders), name: NSNotification.Name(rawValue: "ordersUpdated"), object: nil)
    }
    
    @objc func updateUserOrders() {
        getUserActiveOrders()
    }
    
    func getUserActiveOrders() {
        ExchangeHandler.shared.getAllAvailableSymbols { [weak self] (symbols, error) in
            self?.acountHandler.getUserActiveOrders { (activeOrders, error) in
                guard error == nil, activeOrders != nil else { return }
                self?.ordersArray = activeOrders!
                self?.viewController.reloadData()
                self?.updateQueuedOrders()
            }
        }
    }
    
    func getUserQueuedOrders() {
        queuedOrdersArray = OrderHandler.shared.loadAllQueuedOrders() ?? []
        queuedOrdersArray.sort { (first, secont) -> Bool in
            return first.orderId.doubleValue < secont.orderId.doubleValue
        }
    }
    
    func deleteQueuedOrder(model: QueuedOrderObject) {
        if OrderHandler.shared.deleteQueuedOrder(object: model) {
            getUserQueuedOrders()
            viewController.reloadData()
        }
    }
    
    func updateQueuedOrders() {
        var orderIds = [String]()
        for activeOrder in self.ordersArray {
            if let _id = activeOrder.orderId {
                orderIds.append("\(_id)")
            }
        }
        
        if let queuedOrders = OrderHandler.shared.loadAllQueuedOrders() {
            for order in queuedOrders {
                if !orderIds.contains(order.orderId) {
                    deleteQueuedOrder(model: order)
                }
            }
        }
        
        getUserQueuedOrders()
        viewController.reloadData()
    }
}
