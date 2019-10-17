//
//  systemBRAIN.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 7/20/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
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
                print("executionReportReceived ----------> BUY ORDER FILLED, TIME TO SELL!")
                self.placeSellOrderForExecutedBuyOrder(report: report) { (response, error) in
                    guard error == nil else {
                        return
                    }
                }
                break
            case .SELL:
                break
            }
            break
            
        case .FILLED:
            switch report.side! {
            case .BUY:
                print("executionReportReceived ----------> BUY ORDER FILLED, TIME TO SELL!")
                self.placeSellOrderForExecutedBuyOrder(report: report) { (response, error) in
                    guard error == nil else {
                        return
                    }
                }
                break
            case .SELL:
                if let symbol = report.symbol {
                    if let stop = stopPricesDictionary[symbol], let limit = stopLimitPricesDictionary[symbol] {
                        OrdersCasheHandler.shared.sellOrderFullfieled(report: report, stopPrice: stop, stopLimitPrice: limit)
                    }
                }
                break
            }
            break
            
        case .CANCELED:
            OrdersCasheHandler.shared.sellOrderCanceled(report: report)
            break
            
        case .EXPIRED:
            OrdersCasheHandler.shared.sellOrderCanceled(report: report)
            break
            
        case .REJECTED:
            
            break
        default:
            break
        }
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
    
    func placeSellOrderForExecutedBuyOrder(report: ExecutionReport, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        guard let targetsArray = self.targetsDictionary[report.symbol!], targetsArray.count > 0 else {
            print("placeSellOrderForExecutedBuyOrder ----------> ERROR:: Please specify target array")
            response(nil, "Please specify target array")
            return
        }
        
        let percentArray = calculatePercentageBasedOn(targets: targetsArray)
        
        ExchangeManager.shared.getAllAvailableSymbols { (symbolsArray, error) in
            guard error == nil, symbolsArray != nil else {
                print("placeSellOrderForExecutedBuyOrder ----------> ERROR:: Could not fetch sumbols array")
                response(nil, "Could not fetch sumbols array")
                return
            }
            
            let symbol = symbolsArray?.filter({ $0.symbol == report.symbol! }).first!
            
            if percentArray.count > 0 {
                self.placeSellOrderFor(type: .OCO, asset: symbol?.baseAsset ?? "", currency: symbol?.quoteAsset ?? "", side: .SELL, price: targetsArray, stopPrice: self.stopPricesDictionary[report.symbol!]!, stopLimitPrice: self.stopLimitPricesDictionary[report.symbol!]!, percentages: percentArray) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
            }
        }
    }
    
    private func placeSellOrderFor(type: OrderTypes, asset: String, currency: String , side: OrderSide, price: [String], stopPrice: String, stopLimitPrice: String, percentages: [String], response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        var targets = price
        let targetPrice = targets.remove(at: 0)
        
        var updatablePercentArray = percentages
        let percent = updatablePercentArray.remove(at: 0)
        
        print("placeSellOrderFor ----------> NEW SELL ORDER REQUEST SENT TO ORDER HANDLER")
        orderHandler.placeNewOrderWith(type: type, asset: asset, currency: currency, side: side, price: targetPrice, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentage: percent) { (result, error) in
            guard error == nil, result != nil else {
                
                if error == "Quantity does not meet minimum amount" {
                    print("orderHandler.placeNewOrderWith ----------> ERROR:: Quantity does not meet minimum amount, place 100%")
                    
                    updatablePercentArray = ["100"]
                    
                    self.placeSellOrderFor(type: type, asset: asset, currency: currency, side: side, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentages: updatablePercentArray) { (result, error) in
                        guard error == nil, result != nil else {
                            response(nil, error)
                            return
                        }
                        response(result, nil)
                    }
                    return
                } else {
                    response(nil, error)
                    return
                }
                
            }
            print("orderHandler.placeNewOrderWith ----------> SUCCECCFULLY PLACED ORDER!")
            
            if updatablePercentArray.count > 0 {
                self.placeSellOrderFor(type: type, asset: asset, currency: currency, side: side, price: targets, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentages: updatablePercentArray) { (result, error) in
                    guard error == nil, result != nil else {
                        response(nil, error)
                        return
                    }
                    response(result, nil)
                }
            } else {
                response(result, nil)
            }
        }
    }
    
    private func calculatePercentageBasedOn(targets: [String]) -> [String] {
        switch targets.count {
        case 1:
            return ["100"]
        case 2:
            return ["50","100"]
        case 3:
            return ["35","50","100"]
        case 4:
            return ["25","35","50","100"]
        case 5:
            return ["20","25","35","50","100"]
        default:
            return ["100"]
        }
    }
}


