//
//  OrderHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 7/20/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
import SugarRecord
import CoreData

class OrderHandler: NSObject {
    
    public static let shared = OrderHandler()
    var queuedOrdersDic = [String: QueuedOrderObject]()
    var stopPriceCounter = [String: [String: Double]]()

    var stopPriceUpdateTimer: Timer?
    
    lazy var db: CoreDataDefaultStorage = {
        let store = CoreDataStore.named("cd_basic")
        let bundle = Bundle(for: OrderHandler.classForCoder())
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    let accountServices = AccountServices.shared
    
    func automaticallyPlaceNewOrderWith(type: OrderTypes, asset: String, currency: String , side: OrderSide, price: String, stopPrice: String? = nil, stopLimitPrice: String? = nil, percentage: String,  completion: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {

        var baseAsset: String = ""
        var quoteAsset: String = ""

        if side == OrderSide.BUY {
            baseAsset = asset
            quoteAsset = currency
        } else {
            baseAsset = currency
            quoteAsset = asset
        }

        quantityFor(asset: asset, currency: currency, baseAssset: baseAsset, quoteAsset: quoteAsset, side: side, percent: percentage, price: price, buyStopLimitPrice: stopLimitPrice) { (quantity, error) in
            guard error == nil else { return }
            
            
            if let amount = quantity?.toString() {
                NumbersUtilities.shared.formatted(quantity: amount, for: "\(asset)\(currency)") { (newAmount, error) in
                    guard error == nil, newAmount != nil else {
                        completion(nil, error?.localizedDescription)
                        return
                    }
                    
                    self.placeNewOrderWith(type: type, asset: asset, currency: currency, side: side, amount: newAmount ?? "0", price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice) { (result, error) in
                        completion(result, error)
                    }
                }

            } else {
                completion(nil, nil)
            }
        }
    }
    
    func placeNewOrderWith(type: OrderTypes, asset: String, currency: String , side: OrderSide, amount: String, price: String? = nil, stopPrice: String? = nil, stopLimitPrice: String? = nil, completion: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        let timeStamp = NSDate().timeIntervalSince1970 * 1000
        let symbol = "\(asset)\(currency)"
        
        switch type {
        case .LIMIT:
            self.accountServices.postNew_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: amount, price: price ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            break
        case .LIMIT_MAKER:
            self.accountServices.postNew_LIMIT_MAKER_Order(symbol: symbol, side: side, quantity: amount, price: price ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            break
        case .MARKET:
            self.accountServices.postNew_MARKET_Order(symbol: symbol, side: side, quantity: amount, timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            break
        case .OCO:
            self.accountServices.postNewOCOOrder(symbol: symbol, side: side, quantity: amount, price: price ?? "", stopPrice: stopPrice ?? "", stopLimitPrice: stopLimitPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            
            break
        case .STOP_LOSS:
            self.accountServices.postNew_STOP_LOSS_Order(symbol: symbol, side: side, quantity: amount, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            
            break
        case .STOP_LOSS_LIMIT:
            self.accountServices.postNew_STOP_LOSS_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: amount, price: stopLimitPrice ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            break
        case .TAKE_PROFIT:
            self.accountServices.postNew_TAKE_PROFIT_Order(symbol: symbol, side: side, quantity: amount, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            break
        case .TAKE_PROFIT_LIMIT:
            self.accountServices.postNew_TAKE_PROFIT_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: amount, price: price ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    completion(nil, error?.description)
                    return
                }
                completion(result, nil)
            }
            break
        }
    }
    
    func replaceOCOSellOrder(symbol: String, price: String, stopPrice: String, stopLimitPrice: String, quantity: String, completion: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        NSLog("..................................")
        self.accountServices.postNewOCOOrder(symbol: symbol, side: .SELL, quantity: quantity, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, timestamp: NSDate().timeIntervalSince1970 * 1000) { (result, error) in
            guard error == nil else {
                completion(nil, error?.description)
                return
            }
            
            completion(result, nil)
        }
    }
    
    func cancelOCOOrder(symbol: String, orderListId: Int? = nil, listClientOrderId: String? = nil, completion: @escaping(_ result: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        let timeStamp = NSDate().timeIntervalSince1970 * 1000
        
        self.accountServices.cancelOCOOrder(symbol: symbol, orderListId: orderListId, listClientOrderId: listClientOrderId, timestamp: timeStamp) { (result, error) in
            guard error == nil else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            completion(result, nil)
        }
    }
    
    func addPricesForSymbol(symbol: String, targetsArray: [String]?, stopPrice: String?, stopLimitPrice: String?) {
        systemBRAIN.shared.addPricesForSymbol(symbol: symbol, targetsArray: targetsArray, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice)
    }
    
    private func currentUserCredit(currency: String, completion: @escaping(_ balance: BalanceObject?, _ error: ApiError?) -> Swift.Void) {
        return AccountHandler.shared.getCurrentUserCredit() { ( info, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            if let balances = info?.balances?.filter({ $0.asset == currency }), balances.count > 0 {
                completion(balances.first, nil)
                return
            }
            completion(nil, nil)
        }
    }
    
    func quantityFor(asset: String, currency: String, baseAssset: String, quoteAsset: String, side: OrderSide, percent: String, price: String, buyStopLimitPrice: String? = nil, completion: @escaping(_ quantity: Double?, _ error: String?) -> Swift.Void) {
        self.currentUserCredit(currency: quoteAsset) { (balance, error) in
            guard error == nil, balance != nil else {
                completion(0, error?.localizedDescription)
                return
            }
                        
            ExchangeHandler.shared.getSymbol(symbol: "\(asset)\(currency)") { (symbol, error) in
                guard error == nil, symbol != nil else {
                    completion(0, error?.localizedDescription)
                    return
                }
                
                if let lotSizeArray = symbol!.filters?.filter({ $0.filterType == .LOT_SIZE }), lotSizeArray.count > 0 {
                    let lotSizeFilter = lotSizeArray[0]
                    
                    var quantity = 0.0
                    let checkPrice: String = (buyStopLimitPrice != nil) ? buyStopLimitPrice! : price
                    
                    if side == .SELL {
                        quantity = round((balance!.free!.doubleValue * 0.99 * percent.doubleValue) / 100 * 10000000) / 10000000
                    } else {
                        quantity = round((balance!.free!.doubleValue * 0.99 * (percent.doubleValue / 100)) / checkPrice.doubleValue * 100000) / 100000
                    }
                    
                    if quantity < lotSizeFilter.minQty!.doubleValue {
                        completion(nil, "Order quantity is less than minimum size")
                        return
                    }
                    
                    if quantity > lotSizeFilter.maxQty!.doubleValue {
                        completion(nil, "Order quantity is more than maximum size")
                        return
                    }
                    
                    let multiplyer = Int(quantity / lotSizeFilter.stepSize!.doubleValue)
                    quantity = lotSizeFilter.minQty!.doubleValue * Double(multiplyer)
                    
                    let roundedQuantity = round(quantity * 1000000) / 1000000
                    completion(roundedQuantity, nil)
                    
                }
            }
        }
    }
    
    
    func amountsFor(targets: [String], total: String, symbol: String, completion: @escaping(_ amounts: [String: String]?, _ error: String?) -> Swift.Void) {
        
        NumbersUtilities.shared.formatted(quantity: (total.doubleValue / Double(targets.count)).toString(), for: symbol, completion: { (slice, error) in
            guard error == nil, slice != nil else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            var amountsDic = [String: String]()
            if let slice = slice {
                
                var summed: Double = 0
                
                for i in 0..<targets.count {
                    var amount: Double = 0
                    if i == targets.count - 1 {
                        amount = total.doubleValue - summed
                    } else {
                        amount = slice.doubleValue
                        summed = summed + amount
                    }
                    amountsDic[targets[i]] = amount.toString()
                }
            }
            
            completion(amountsDic, nil)
        })
    }
    
    func insertQueuedOrders(array: [QueuedOrderObject]) {
        if array.count > 0 {
            for order in array {
                self.queuedOrdersDic[order.asset+order.currency] = order
                try! db.operation { (context, save) -> Void in
                    let _object: BasicOrderObject = try! context.new()
                    _object.asset = order.asset
                    _object.currency = order.currency
                    _object.price = order.price
                    _object.stopPrice = order.stopPrice
                    _object.stopLimitPrice = order.stopLimitPrice
                    _object.amount = order.amount
                    _object.orderId = order.orderId
                    _object.uniqueId = order.uniqueId
                    try! context.insert(_object)
                    save()
                }
            }
        }
    }
    
    func validatQueuedOrderWithCurrentActiveOrders() {
        
    }
    
    public func sellOrderFullfieled(report: ExecutionReport) {
        if let index = PumpHandler.shared.activeOrders.index(of: report.symbol!) {
            PumpHandler.shared.activeOrders.remove(at: index)
        }
        
        if report.orderType != .LIMIT_MAKER { return }
        AccountHandler.shared.getUserActiveOrders { [weak self] (activeOrders, error) in
            if let sellOrders = activeOrders?.filter({ $0.side == .SELL && $0.type == .LIMIT_MAKER && $0.symbol == report.symbol }), sellOrders.count > 0 {
                for order in sellOrders {
                    if order.stopPrice?.doubleValue ?? 0 < (report.orderPrice?.doubleValue ?? 0) * 95 / 100 {
                        self?.cancelOCOOrder(symbol: order.symbol ?? "", orderListId: order.orderListId ?? 0) { (result, error) in
                            if result != nil, error == nil {
                                if let stopLossOrder = result?.orderReports?.filter({ $0.type == OrderTypes.STOP_LOSS_LIMIT }), stopLossOrder.count > 0 {
                                    let stopPrice = stopLossOrder[0].stopPrice
                                    let stopLimit = stopLossOrder[0].price
                                    self?.placeNewUpdatedSellOrder(with: report, price: order.price ?? "0" , stopPrice: stopPrice ?? "0", stopLimitPrice: stopLimit ?? "0", newStopPrice: report.orderPrice ?? "0")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func placeNewUpdatedSellOrder(with order: ExecutionReport, price: String, stopPrice: String, stopLimitPrice: String, newStopPrice: String) {
        let diff = Double(stopPrice.doubleValue) - Double(stopLimitPrice.doubleValue)
        var finalStopPrice = Double(newStopPrice.doubleValue * 95.0 / 100)
        var newStopLimitPrice = Double(finalStopPrice - diff)
        
        ExchangeHandler.shared.getSymbol(symbol: order.symbol ?? "") { (symbol, error) in
            if error != nil {
                AlertUtility.showAlert(title: "Failed to get symbol information")
                return
            }
            
            if let pricefilter = symbol!.filters?.filter({ $0.filterType == .PRICE_FILTER }).first {
                if let tickSize = pricefilter.tickSize {
                    
                    finalStopPrice = round(finalStopPrice * (Double(1) / tickSize.doubleValue)) / (Double(1) / tickSize.doubleValue)
                    newStopLimitPrice = round(newStopLimitPrice * (Double(1) / tickSize.doubleValue)) / (Double(1) / tickSize.doubleValue)
                    
                    NumbersUtilities.shared.formatted(price: finalStopPrice.toString(), for: symbol?.symbol ?? "") { (stopPrice, error) in
                        guard error == nil else {
                            return
                        }
                        NumbersUtilities.shared.formatted(price: newStopLimitPrice.toString(), for: symbol?.symbol ?? "") { (limitPrice, error) in
                            guard error == nil else {
                                return
                            }
                            self.placeNewOrderWith(type: .OCO, asset: symbol?.baseAsset ?? "", currency: symbol?.quoteAsset ?? "", side: .SELL, amount: order.orderQuantity ?? "0", price: price, stopPrice: stopPrice, stopLimitPrice: limitPrice) { (result, error) in
                                 if error != nil {
                                    AlertUtility.showAlert(title: order.symbol ?? "ReSell Failed!", message: error)
                                 }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateStopLossCountDict() {
        for symbol in self.stopPriceCounter.keys {
            let symbolInfo = self.stopPriceCounter[symbol]
            let time = symbolInfo!["time"]
            
            let difference = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSinceNow: time!), to: Date())
            if let minuts = difference.minute, minuts > 5 {
                self.stopPriceCounter.removeValue(forKey: symbol)
            }
        }
    }
    
    func placePumpOrder(for symbol: String, completion: @escaping(_ success: Bool?, _ error: String?) -> Swift.Void) {
        
        if stopPriceUpdateTimer == nil {
            stopPriceUpdateTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(updateStopLossCountDict), userInfo: nil, repeats: true)
            stopPriceUpdateTimer?.fire()
        }
        
        currentFreeBalance(side: .BUY) { (freeBalance, error) in
            guard error == nil, freeBalance != nil, freeBalance! > 0.0 else { return }
            NSLog("Place pump order current balance received \(freeBalance!)")
            var dedicated: Double = 0.0
            
            if freeBalance! >= 0.0030 {
                dedicated = 0.0030
            } else if freeBalance! > 0.001 {
                dedicated = freeBalance!
            } else {
                NSLog("Free balance is too low \(freeBalance!)")
                return
            }
            
            if let _ = self.stopPriceCounter[symbol] {
                self.stopPriceCounter[symbol]!["count"] = self.stopPriceCounter[symbol]!["count"]! + 1.0
                self.stopPriceCounter[symbol]!["time"] = NSDate().timeIntervalSince1970
            } else {
                self.stopPriceCounter[symbol] = ["count":1.0, "time": NSDate().timeIntervalSince1970]
            }
            
            if let symbolObject = ExchangeHandler.shared.getSyncSymbol(symbol: symbol) {
                MarketDataServices.shared.fetchSymbolPriceTicker(symbol: symbol) { (symbolPrice, error) in
                    guard error == nil, symbolPrice != nil else { return }
                    NSLog("Place pump order symbol price received \(symbolPrice!.price!)")

                    NumbersUtilities.shared.formatted(price: (symbolPrice!.price!.doubleValue * self.profitBasedOnMarketSituation()).toString() , for: symbol) { (price, error) in
                        guard error == nil, price != nil else { return }
                        NSLog("Place pump order formatted price \(price!)")

                        let stopLossAmount = self.stopLossValue(symbol: symbol, price: symbolPrice!.price!)
                        NSLog("stopLossAmount \(stopLossAmount)")

                        NumbersUtilities.shared.formatted(price: stopLossAmount.toString(), for: symbol) { (stopPrice, error) in
                            guard error == nil, stopPrice != nil else { return }
                            NSLog("Place pump order formatted stop price \(stopPrice!)")

                            NumbersUtilities.shared.formatted(price: (stopLossAmount * 0.998).toString(), for: symbol) { (limitPrice, error) in
                                guard error == nil, limitPrice != nil else { return }
                                NSLog("Place pump order formatted limit price \(limitPrice!)")

                                NSLog("Raw quantity\((dedicated / price!.doubleValue))")
                                NumbersUtilities.shared.formatted(quantity: (dedicated / price!.doubleValue).toString(), for: symbol) { (quantity, error) in
                                    guard error == nil, quantity != nil else { return }
                                    NSLog("Place pump order formatted quantity \(quantity!)")

                                    self.placeNewOrderWith(type: .MARKET, asset: symbolObject.baseAsset ?? "", currency: symbolObject.quoteAsset ?? "", side: .BUY, amount: quantity!) { (response, error) in
                                        guard error == nil, response != nil else {
                                            NSLog("Failed to place order: \(error ?? "")")
                                            return
                                        }
                                        NSLog("Placed order \(response!.symbol!)")
                                        
                                        NumbersUtilities.shared.formatted(quantity: (response?.origQty!)!, for: symbol) { (amount, error) in
                                            guard error == nil, amount != nil else { return }
                                            
                                            let queuedOrder = QueuedOrderObject(asset: symbolObject.baseAsset!, currency: symbolObject.quoteAsset!, price: price!, stopPrice: stopPrice!, stopLimitPrice: limitPrice!, amount: amount!, orderId: "MARKET_PUMP_\(symbol)", uniqueId: "MARKET_PUMP_\(symbol)_\(amount!)")
                                            
                                            self.insertQueuedOrders(array: [queuedOrder])
                                            NSLog("ORDER INSERTED INTO DATABASE: >>>>>> MARKET_PUMP_\(symbol)")
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                AccountHandler.shared.getCurrentUserCredit { (account, error) in
                                                    guard error == nil, account != nil else {
                                                        return
                                                    }
                                                    
                                                    if let balance = account!.balances?.filter({ $0.asset == symbolObject.baseAsset! }).first {
                                                        if let free = balance.free?.doubleValue {
                                                            NSLog("Preparing to place order after 1.5 seconds! free value: \(free)")
                                                            self.queuedOrdersDic.removeValue(forKey: symbolObject.symbol!)
                                                            
                                                            NumbersUtilities.shared.formatted(quantity: free.toString(), for: symbolObject.symbol!) { (amount, error) in
                                                                NSLog("Formatted ammount: \(amount!)")
                                                                guard error == nil, amount != nil else { return }

                                                                self.placeNewOrderWith(type: .OCO, asset: queuedOrder.asset, currency: queuedOrder.currency, side: .SELL, amount: amount!, price: queuedOrder.price, stopPrice: queuedOrder.stopPrice, stopLimitPrice: queuedOrder.stopLimitPrice) { (response, error) in
                                                                        guard error == nil, response != nil else {
                                                                        NSLog("Failed to place order with error: \(error?.description ?? "")")
                                                                        return
                                                                        }
                                                                NSLog("Successfully placed order")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            completion(true, nil)

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func profitBasedOnMarketSituation() -> Double {
        return 1.004
        let marketFactor = PumpHandler.shared.marketMultiplayer
        switch marketFactor {
        case ..<2:
            return 1.009
        case 2..<5:
            return 1.008
        case 5..<10:
            return 1.007
        case 10..<15:
            return 1.006
        case 15..<20:
            return 1.005
        default:
            return 1.004
        }
    }
    
    func stopLossValue(symbol: String, price: String) -> Double {
        return (price.doubleValue * 0.997)
        if let symbolInfo = stopPriceCounter[symbol] {
            if let count = symbolInfo["count"] {
                switch count {
                case 1.0:
                    return (price.doubleValue * 0.987)
                    
                case 2.0:
                        return (price.doubleValue * 0.990)
                        
                case 3.0:
                        return (price.doubleValue * 0.993)
                        
                case 4.0...1000.0:
                        return (price.doubleValue * 0.995)
                        
                default:
                    break
                }
            }
        }
        
        return (price.doubleValue * 0.987)
    }
    
    private func currentFreeBalance(side: OrderSide, completion:  @escaping(_ balance: Double?, _ error: ApiError?) -> Swift.Void) {
        AccountHandler.shared.getCurrentUserCredit { (account, error) in
            guard error == nil, account != nil else {
                completion(0, error)
                return
            }
            
            if side == .SELL {
                if let balance = account!.balances?.filter({ $0.asset == "BTC" }).first {
                    if let free = balance.free?.doubleValue {
                        completion(free, nil)
                        return
                    }
                    completion(nil, nil)
                }
            } else {
                if let balance = account!.balances?.filter({ $0.asset == "BTC" }).first {
                    if let free = balance.free?.doubleValue {
                        completion(free * 0.999, nil)
                        return
                    }
                    completion(nil, nil)
                }
            }
        }
    }
    
    func loadAllQueuedOrders() -> [QueuedOrderObject]? {
        if let orders = try? db.fetch(FetchRequest<BasicOrderObject>()).map(CoreDataBasicEntity.init) {
            var queuedOrders = [QueuedOrderObject]()
            for order in orders {
                let queuedOrder = QueuedOrderObject(asset: order.asset, currency: order.currency, price: order.price, stopPrice: order.stopPrice, stopLimitPrice: order.stopLimitPrice, amount: order.amount, orderId: order.orderId, uniqueId: "\(order.uniqueId)")
                queuedOrders.append(queuedOrder)
            }
            return queuedOrders
        }
        return nil
    }
    
    func queuedOrdersWith(orderId: String) -> [QueuedOrderObject]? {
        if var allOrders = loadAllQueuedOrders() {
            allOrders = allOrders.filter({ $0.orderId == orderId })
            return allOrders
        }
        return nil
    }
    
    func deleteQueuedOrder(object: QueuedOrderObject) -> Bool {
        if var orders = queuedOrdersWith(orderId: object.orderId), orders.count > 0  {
            if orders.count == 1 {
                return delete(object: orders[0])
            }
            orders = orders.filter({ $0.price != object.price })
            _ = delete(object: object)
            updateOtherOrdersAndDelete(order: object, allOrders: orders)
            return true
        }
        return true
    }
    
    func updateOtherOrdersAndDelete(order: QueuedOrderObject, allOrders: [QueuedOrderObject]) {
        var targets = [String]()
        var amount = floor(order.amount.doubleValue * 10000000) / 10000000
        
        for queuedOrder in allOrders {
            targets.append(queuedOrder.price)
            amount = amount + floor(queuedOrder.amount.doubleValue * 10000000) / 10000000
            _ = delete(object: queuedOrder)
        }
        
        amountsFor(targets: targets, total: amount.toString(), symbol: order.asset + order.currency) { (amountsDic, error) in
            if amountsDic != nil, error == nil {
                var queuedOrders = [QueuedOrderObject]()
                for target in targets {
                    let queuedOrder = QueuedOrderObject(asset: order.asset, currency: order.currency, price: target, stopPrice: order.stopPrice, stopLimitPrice: order.stopLimitPrice, amount: amountsDic![target]!, orderId: order.orderId, uniqueId: "\(order.uniqueId)")
                    queuedOrders.append(queuedOrder)
                }
                OrderHandler.shared.insertQueuedOrders(array: queuedOrders)
            }
        }
    }
    
    private func delete(object: QueuedOrderObject) -> Bool {
        try! db.operation({ (context, save) -> Void in
            guard let obj = try! context.request(BasicOrderObject.self).filtered(with: NSPredicate(format: "uniqueId = %@ AND asset = %@ AND currency = %@",object.uniqueId, object.asset, object.currency, object.price)).fetch().first else { return }
            _ = try? context.remove(obj)
            save()
            
        })
        return true
    }

}
