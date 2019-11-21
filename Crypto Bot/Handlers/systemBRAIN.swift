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
                print("executionReportReceived ----------> NEW BUY ORDER PLACED")
                break
            case .SELL:
                print("NEW SELL ORDER PLACED")
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
                print("executionReportReceived ----------> BUY ORDER FILLED, TIME TO SELL!")
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
        }
    }
    
//    private func placeSellOrderFor(type: OrderTypes, asset: String, currency: String , side: OrderSide, price: [String], stopPrice: String, stopLimitPrice: String, percentages: [String], completion: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
//
//        var targets = price
//        let targetPrice = targets.remove(at: 0)
//
//        var updatablePercentArray = percentages
//        let percent = updatablePercentArray.remove(at: 0)
//
//        orderHandler.automaticallyPlaceNewOrderWith(type: type, asset: asset, currency: currency, side: side, price: targetPrice, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentage: percent) { (result, error) in
//            guard error == nil, result != nil else {
//
//                if error == "Quantity does not meet minimum amount" {
//                    updatablePercentArray = ["100"]
//
//                    self.placeSellOrderFor(type: type, asset: asset, currency: currency, side: side, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentages: updatablePercentArray) { (result, error) in
//                        guard error == nil, result != nil else {
//                            completion(nil, error)
//                            return
//                        }
//                        completion(result, nil)
//                    }
//                    return
//                } else {
//                    completion(nil, error)
//                    return
//                }
//
//            }
//
//            if updatablePercentArray.count > 0 {
//                self.placeSellOrderFor(type: type, asset: asset, currency: currency, side: side, price: targets, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentages: updatablePercentArray) { (result, error) in
//                    guard error == nil, result != nil else {
//                        completion(nil, error)
//                        return
//                    }
//                    completion(result, nil)
//                }
//            } else {
//                completion(result, nil)
//            }
//        }
//    }
//
//    private func calculatePercentageBasedOn(targets: [String]) -> [String] {
//        switch targets.count {
//        case 1:
//            return ["100"]
//        case 2:
//            return ["50","100"]
//        case 3:
//            return ["35","50","100"]
//        case 4:
//            return ["25","35","50","100"]
//        case 5:
//            return ["20","25","35","50","100"]
//        default:
//            return ["100"]
//        }
//    }
}


