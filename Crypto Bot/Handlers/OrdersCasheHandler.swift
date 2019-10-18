//
//  OrdersCasheHandler.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/17/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class OrdersCasheHandler {
    
    public static let shared = OrdersCasheHandler()
    
    private var activeSellOrders = [String:[OrderResponseObject]]()
    
    public func newSellOrderPlaced(response: OrderResponseObject) {
        if let symbol = response.symbol {
            if var activeOrders = activeSellOrders[symbol] {
                activeOrders.append(response)
                activeSellOrders[symbol] = activeOrders
            } else {
                activeSellOrders[symbol] = [response]
            }
        }
    }
    
    public func sellOrderCanceled(report: ExecutionReport) {
        if let symbol = report.symbol {
            guard self.activeSellOrders[symbol] != nil else {
                return
            }
            
            self.activeSellOrders[symbol] = self.activeSellOrders[symbol]?.filter({ $0.orderListId! != report.orderId })
        }
    }
    
    public func sellOrderFullfieled(report: ExecutionReport, stopPrice: String, stopLimitPrice: String) {
        if let symbol = report.symbol {
            guard self.activeSellOrders[symbol] != nil else {
                return
            }
            
            self.activeSellOrders[symbol] = self.activeSellOrders[symbol]?.filter({ $0.orderListId! != report.orderId })

            if let activeOrders = activeSellOrders[symbol] {
                if activeOrders.count >= 1 {
                    if let price = report.orderPrice {
                        for order in activeOrders {
                            if let orderId = order.listClientOrderId {
                                OrderHandler.shared.cancelOCOOrder(symbol: symbol, listClientOrderId: orderId) { (success, error) in

                                    if (success ?? false) {
                                        self.activeSellOrders[symbol] = self.activeSellOrders[symbol]?.filter({ $0.listClientOrderId != orderId })
                                        self.placeNewUpdatedSellOrder(with: order, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, newStopPrice: price)
                                    }
                                }
                            } else {
                                print("listClientOrderId IS FUCKING EMPTY")
                            }
                        }
                    } else {
                        print("PRICE IS FUCKING EMPTY")
                    }
                } else {
                    activeSellOrders[symbol] = nil
                }
            }
        }
        print("SYMBOL IS FUCKING EMPTY")
    }
    
    private func placeNewUpdatedSellOrder(with order: OrderResponseObject, stopPrice: String, stopLimitPrice: String, newStopPrice: String) {
        let diff = Double(stopPrice.doubleValue) - Double(stopLimitPrice.doubleValue)
        let finalStopPrice = Double(newStopPrice.doubleValue * 95.0 / 100)
        let newStopLimitPrice = round(Double(finalStopPrice - diff) * 10000000) / 10000000
        
        if let limitMakerOrder  = order.orderReports?.filter({ $0.type == .LIMIT_MAKER }).first {
            OrderHandler.shared.replaceOCOSellOrder(symbol: order.symbol!, price: limitMakerOrder.price!, stopPrice: "\(finalStopPrice)", stopLimitPrice: "\(newStopLimitPrice)", quantity: limitMakerOrder.origQty!) { (result, error) in
                if error != nil {
                    AlertUtility.showAlert(title: order.symbol ?? "ReSell Failed!", message: error)
                }
            }
        }
    }
    
}
