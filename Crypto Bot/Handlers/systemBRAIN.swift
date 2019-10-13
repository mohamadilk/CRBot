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
    
    var targetsArray = ["0.021900","0.021920","0.021930"]

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
                print("NEW BUY ORDER PLACED")
                break
            case .SELL:
                print("NEW CELL ORDER PLACED")
                break
            }
            break
            
        case .FILLED, .PARTIALLY_FILLED:
            self.placeSellOrderForExecutedBuyOrder(report: report) { (response, error) in
                guard error == nil else {
                    return
                }
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
    }
    
    func outboundAccountinfoReceived(Info: OutboundAccountInfo) {

    }
    
    
    func placeSellOrderForExecutedBuyOrder(report: ExecutionReport, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        let targetsArray = ["0.021900","0.021920","0.021930"]
        let percentArray = calculatePercentageBasedOn(targets: targetsArray)
        
        ExchangeManager.shared.getAllAvailableSymbols { (symbolsArray, error) in
            guard error == nil, symbolsArray != nil else {
             
                return
            }
            
            let symbol = symbolsArray?.filter({ $0.symbol == report.symbol! }).first!
            
            if percentArray.count > 0 {
                self.placeSellOrderFor(type: .OCO, asset: symbol?.baseAsset ?? "", currency: symbol?.quoteAsset ?? "", side: .SELL, price: targetsArray[0], stopPrice: "0.021740", stopLimitPrice: "0.021750", percentages: percentArray) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
            }
        }
    }
    
    private func placeSellOrderFor(type: OrderTypes, asset: String, currency: String , side: OrderSide, price: String, stopPrice: String, stopLimitPrice: String, percentages: [String], response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        let targetPrice = self.targetsArray.remove(at: 0)
        var updatablePercentArray = percentages
        let percent = updatablePercentArray.remove(at: 0)
        
        orderHandler.placeNewOrderWith(type: type, asset: asset, currency: currency, side: side, price: targetPrice, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentage: percent) { (result, error) in
            guard error == nil, result != nil else {
                if error == "Quantity does not meet minimum amount" {
                    updatablePercentArray = ["100"]
                    
                    self.placeSellOrderFor(type: type, asset: asset, currency: currency, side: side, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentages: updatablePercentArray) { (result, error) in
                        guard error == nil, result != nil else {
                            response(nil, error)
                            return
                        }
                        response(result, nil)
                    }
                }
                response(nil, error)
                return
            }
            
            if updatablePercentArray.count > 0 {
                self.placeSellOrderFor(type: type, asset: asset, currency: currency, side: side, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, percentages: updatablePercentArray) { (result, error) in
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


