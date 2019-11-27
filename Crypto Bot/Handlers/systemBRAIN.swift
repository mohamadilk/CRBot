//
//  systemBRAIN.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 7/20/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
import NotificationCenter

class systemBRAIN {
    
    public static let shared = systemBRAIN()
    
    var targetsDictionary = [String: Array<String>]()
    var stopPricesDictionary = [String: String]()
    var stopLimitPricesDictionary = [String: String]()
    
    
    let streamHandler = UserStreamHandler.shared
    let orderHandler = OrderHandler.shared
    
    init() {
        self.streamHandler.delegate = self
    }
    
}

extension systemBRAIN: UserStreamHandlerDelegate {
    func executionReportReceived(report: ExecutionReport) {
        switch report.currentOrderStatus {
        case .NEW:
            switch report.side! {
            case .BUY:
//                print("executionReportReceived ----------> NEW BUY ORDER PLACED")
                break
            case .SELL:
//                print("NEW SELL ORDER PLACED")
                break
            }
            break
            
        case .PARTIALLY_FILLED:
            switch report.side! {
            case .BUY:

                break
            case .SELL:
                break
            }
            break
            
        case .FILLED:
            switch report.side! {
            case .BUY:
//                print("executionReportReceived ----------> BUY ORDER FILLED, TIME TO SELL!")
                self.placeSellOrderForExecutedBuyOrder(report: report) { (success, error) in
                    guard error == nil else {
                        return
                    }
                }
                break
            case .SELL:
                orderHandler.sellOrderFullfieled(report: report)
                break
            }
            break
            
        case .CANCELED:
            break
            
        case .EXPIRED:
            break
            
        case .REJECTED:
            
            break
        default:
            break
        }
        NotificationCenter.default.post(name: Notification.Name("ordersUpdated"), object: nil)
    }
    
    func outboundAccountinfoReceived(Info: OutboundAccountInfo) {
        
    }
    
    func addPricesForSymbol(symbol: String, targetsArray: [String]?, stopPrice: String?, stopLimitPrice: String?) {
        
        if let targets = targetsArray, targets.count > 0 {
            targetsDictionary[symbol] = targets
        }
        
        if let stop = stopPrice {
            stopPricesDictionary[symbol] = stop
        }
        
        if let stopLimit = stopLimitPrice {
            stopLimitPricesDictionary[symbol] = stopLimit
        }
    }
    
    func placeSellOrderForExecutedBuyOrder(report: ExecutionReport, completion: @escaping(_ success: Bool?, _ error: String?) -> Swift.Void) {
        
        if let queuedOrders = orderHandler.loadAllQueuedOrders()?.filter({ $0.orderId == "\(report.orderId ?? 0)" }), queuedOrders.count > 0 {
           
            var count = 0
            for queuedOrder in queuedOrders {
                orderHandler.placeNewOrderWith(type: .OCO, asset: queuedOrder.asset, currency: queuedOrder.currency, side: .SELL, amount: queuedOrder.amount, price: queuedOrder.price, stopPrice: queuedOrder.stopPrice, stopLimitPrice: queuedOrder.stopLimitPrice) { (response, error) in
                    count += 1
                    
                    if count == queuedOrders.count {
                        completion(true, nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let queuedOrders = self.orderHandler.loadAllQueuedOrders()?.filter({ $0.orderId == "MARKET_PUMP_\(report.symbol!)" }), queuedOrders.count > 0 {
                    let queuedOrder = queuedOrders[0]

                    self.orderHandler.placeNewOrderWith(type: .OCO, asset: queuedOrder.asset, currency: queuedOrder.currency, side: .SELL, amount: queuedOrder.amount, price: queuedOrder.price, stopPrice: queuedOrder.stopPrice, stopLimitPrice: queuedOrder.stopLimitPrice) { (response, error) in
                        guard error == nil, response != nil else {
                            completion(false, error)
                            print(error ?? "")
                            return
                        }
                        completion(true, nil)
                    }
                } else {
                    if let queuedOrder = self.orderHandler.queuedOrdersDic[report.symbol!] {
                        self.orderHandler.queuedOrdersDic.removeValue(forKey: report.symbol!)
                        self.orderHandler.placeNewOrderWith(type: .OCO, asset: queuedOrder.asset, currency: queuedOrder.currency, side: .SELL, amount: queuedOrder.amount, price: queuedOrder.price, stopPrice: queuedOrder.stopPrice, stopLimitPrice: queuedOrder.stopLimitPrice) { (response, error) in
                            guard error == nil, response != nil else {
                                completion(false, error)
                                print(error ?? "")
                                return
                            }
                            completion(true, nil)
                        }

                    }
                }
            }
        }
    }
}


