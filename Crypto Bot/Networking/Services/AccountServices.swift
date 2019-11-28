//
//  AccountServices.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

fileprivate struct Keys
{
    fileprivate struct endPoints {
        fileprivate static let order = "/api/v3/order"
        fileprivate static let openOrders = "/api/v3/openOrders"
        fileprivate static let allOrders = "/api/v3/allOrders"
        fileprivate static let testOrder = "/api/v3/order/test"
        fileprivate static let ocoOrder = "/api/v3/order/oco"
        fileprivate static let cancelOco = "/api/v3/orderList"
        fileprivate static let queryOco = "/api/v3/orderList"
        fileprivate static let queryAllOcos = "/api/v3/allOrderList"
        fileprivate static let queryOpenOcos = "/api/v3/openOrderList"
        fileprivate static let accountInformation = "/api/v3/account" // 5
        fileprivate static let accountTradeList = "/api/v3/myTrades"
        fileprivate static let userDataStream = "/api/v3/userDataStream"
    }
    
    fileprivate struct parameterKeys {
        fileprivate static let symbol = "symbol"
        fileprivate static let side = "side"
        fileprivate static let type = "type"
        fileprivate static let timeInForce = "timeInForce"
        fileprivate static let quantity = "quantity"
        fileprivate static let price = "price"
        fileprivate static let newClientOrderId = "newClientOrderId"
        fileprivate static let icebergQty = "icebergQty"
        fileprivate static let stopPrice = "stopPrice"
        fileprivate static let newOrderRespType = "newOrderRespType"
        fileprivate static let recvWindow = "recvWindow"
        fileprivate static let timestamp = "timestamp"
        fileprivate static let origClientOrderId = "origClientOrderId"
        fileprivate static let orderId = "orderId"
        fileprivate static let startTime = "startTime"
        fileprivate static let endTime = "endTime"
        fileprivate static let limit = "limit"
        fileprivate static let stopClientOrderId = "stopClientOrderId"
        fileprivate static let listClientOrderId = "listClientOrderId"
        fileprivate static let limitClientOrderId = "limitClientOrderId"
        fileprivate static let limitIcebergQty = "limitIcebergQty"
        fileprivate static let stopLimitPrice = "stopLimitPrice"
        fileprivate static let stopIcebergQty = "stopIcebergQty"
        fileprivate static let stopLimitTimeInForce = "stopLimitTimeInForce"
        fileprivate static let orderListId = "orderListId"
        fileprivate static let fromId = "fromId"
        
    }
}

class AccountServices: BaseApiServices {
    
    static let shared = AccountServices()
    
    func postNew_LIMIT_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce, quantity: String, price: String, newClientOrderId: String? = nil, icebergQty: Int? = nil, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.LIMIT.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.price: price,
                          Keys.parameterKeys.timeInForce: timeInForce,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        if let icebergQty = icebergQty { parameters[Keys.parameterKeys.icebergQty] = icebergQty }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func postNew_MARKET_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce? = nil, quantity: String, price: String? = nil, newClientOrderId: String? = nil, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.MARKET.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let timeInForce = timeInForce { parameters[Keys.parameterKeys.timeInForce] = timeInForce }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        if let price = price { parameters[Keys.parameterKeys.price] = price }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func postNew_STOP_LOSS_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce? = nil, quantity: String, price: String? = nil, newClientOrderId: String? = nil, stopPrice: String, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.STOP_LOSS.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!,
                          Keys.parameterKeys.stopPrice: stopPrice] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let timeInForce = timeInForce { parameters[Keys.parameterKeys.timeInForce] = timeInForce }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        if let price = price { parameters[Keys.parameterKeys.price] = price }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func postNew_STOP_LOSS_LIMIT_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce, quantity: String, price: String, newClientOrderId: String? = nil, stopPrice: String, icebergQty: Int? = nil, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.STOP_LOSS_LIMIT.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!,
                          Keys.parameterKeys.timeInForce: timeInForce,
                          Keys.parameterKeys.price: price,
                          Keys.parameterKeys.stopPrice: stopPrice] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        if let icebergQty = icebergQty { parameters[Keys.parameterKeys.icebergQty] = icebergQty }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func postNew_TAKE_PROFIT_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce? = nil, quantity: String, price: String? = nil, newClientOrderId: String? = nil, stopPrice: String, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.TAKE_PROFIT.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!,
                          Keys.parameterKeys.stopPrice: stopPrice] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let timeInForce = timeInForce { parameters[Keys.parameterKeys.timeInForce] = timeInForce }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        if let price = price { parameters[Keys.parameterKeys.price] = price }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func postNew_TAKE_PROFIT_LIMIT_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce, quantity: String, price: String, newClientOrderId: String? = nil, stopPrice: String, icebergQty: Int? = nil, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.TAKE_PROFIT_LIMIT.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!,
                          Keys.parameterKeys.timeInForce: timeInForce,
                          Keys.parameterKeys.price: price,
                          Keys.parameterKeys.stopPrice: stopPrice] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        if let icebergQty = icebergQty { parameters[Keys.parameterKeys.icebergQty] = icebergQty }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func postNew_LIMIT_MAKER_Order(symbol: String, side: OrderSide, timeInForce: TimeInForce? = nil, quantity: String, price: String, newClientOrderId: String? = nil, newOrderRespType: newOrderRespType? = nil, recvWindow: UInt? = nil, timestamp: TimeInterval, completion: @escaping(_ order: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var parameters = [Keys.parameterKeys.symbol: symbol,
                          Keys.parameterKeys.side: side,
                          Keys.parameterKeys.type: OrderTypes.LIMIT_MAKER.rawValue,
                          Keys.parameterKeys.quantity: quantity,
                          Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!,
                          Keys.parameterKeys.price: price] as [String : Any]
        
        if let newClientOrderId = newClientOrderId { parameters[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let newOrderRespType = newOrderRespType { parameters[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        if let timeInForce = timeInForce { parameters[Keys.parameterKeys.timeInForce] = timeInForce }
        if let recvWindow = recvWindow { parameters[Keys.parameterKeys.recvWindow] = recvWindow }
        
        postNewOrder(parameters: parameters) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    private func postNewOrder(parameters: [String:Any], completion: @escaping(_ orderBook: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.order, type: .mappableJsonType, method: .post, body: nil, parameters: parameters, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let orderModel = OrderResponseObject(JSON: value.dictionary as [String : Any])
            completion(orderModel, nil)
        }
    }
    
    func fetchOrderStatus(symbol: String, orderId: UInt? = nil, origClientOrderId: String? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: OrderDetailObject?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.symbol: symbol,
                      Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let orderId = orderId { params[Keys.parameterKeys.orderId] = orderId }
        if let origClientOrderId = origClientOrderId { params[Keys.parameterKeys.origClientOrderId] = origClientOrderId }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.order, type: .mappableJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let orderModel = OrderDetailObject(JSON: value.dictionary as [String : Any])
            completion(orderModel, nil)
        }
    }
    
    func cancelOrder(symbol: String, orderId: UInt? = nil, origClientOrderId: String? = nil, newClientOrderId: String? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: OrderDetailObject?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.symbol: symbol,
                      Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let orderId = orderId { params[Keys.parameterKeys.orderId] = orderId }
        if let origClientOrderId = origClientOrderId { params[Keys.parameterKeys.origClientOrderId] = origClientOrderId }
        if let newClientOrderId = newClientOrderId { params[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.order, type: .mappableJsonType, method: .delete, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let orderModel = OrderDetailObject(JSON: value.dictionary as [String : Any])
            completion(orderModel, nil)
        }
    }
    
    
    func fetchOpenOrders(symbol: String? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: [OrderDetailObject]?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let symbol = symbol { params[Keys.parameterKeys.symbol] = symbol }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.openOrders, type: .arrayOfJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [OrderDetailObject]()
            for model in value.array {
                let orderModel = OrderDetailObject(JSON: model as [String : Any])
                modelsArray.append(orderModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
    
    func fetchAllOrders(symbol: String, limit: Int? = nil, orderId: UInt? = nil, startTime: TimeInterval? = nil, endTime: TimeInterval? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: [OrderDetailObject]?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.symbol: symbol,
                      Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let limit = limit { params[Keys.parameterKeys.limit] = limit }
        if let orderId = orderId { params[Keys.parameterKeys.orderId] = orderId }
        if let startTime = startTime { params[Keys.parameterKeys.startTime] = startTime }
        if let endTime = endTime { params[Keys.parameterKeys.endTime] = endTime }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.allOrders, type: .arrayOfJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [OrderDetailObject]()
            for model in value.array {
                let orderModel = OrderDetailObject(JSON: model as [String : Any])
                modelsArray.append(orderModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
    
    func postNewOCOOrder(symbol: String, listClientOrderId: String? = nil, side: OrderSide, quantity: String, limitClientOrderId: String? = nil, price: String, limitIcebergQty: Int? = nil, stopClientOrderId: String? = nil, stopPrice: String, stopLimitPrice: String, stopIcebergQty: Int? = nil, stopLimitTimeInForce: TimeInForce? = .GTC, newOrderRespType: responseType? = nil, recvWindow: Int? = 60000, timestamp: TimeInterval, completion: @escaping(_ orderBook: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.symbol: symbol,
                      Keys.parameterKeys.side: side,
                      Keys.parameterKeys.quantity: quantity,
                      Keys.parameterKeys.price: price,
                      Keys.parameterKeys.stopPrice: stopPrice,
                      Keys.parameterKeys.stopLimitPrice: stopLimitPrice,
                      Keys.parameterKeys.timestamp: "\(Int(round(timestamp)))".components(separatedBy: ".").first!] as [String : Any]
        
        print(Int(round(timestamp)))
        if let listClientOrderId = listClientOrderId { params[Keys.parameterKeys.listClientOrderId] = listClientOrderId }
        if let limitClientOrderId = limitClientOrderId { params[Keys.parameterKeys.limitClientOrderId] = limitClientOrderId }
        if let limitIcebergQty = limitIcebergQty { params[Keys.parameterKeys.limitIcebergQty] = limitIcebergQty }
        if let stopClientOrderId = stopClientOrderId { params[Keys.parameterKeys.stopClientOrderId] = stopClientOrderId }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow } else { params[Keys.parameterKeys.recvWindow] = 6000 }
        if let stopIcebergQty = stopIcebergQty { params[Keys.parameterKeys.stopIcebergQty] = stopIcebergQty }
        if let stopLimitTimeInForce = stopLimitTimeInForce { params[Keys.parameterKeys.stopLimitTimeInForce] = stopLimitTimeInForce }
        if let newOrderRespType = newOrderRespType { params[Keys.parameterKeys.newOrderRespType] = newOrderRespType }
        
        self.request(endpoint: Keys.endPoints.ocoOrder, type: .mappableJsonType, method: .post, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let orderModel = OrderResponseObject(JSON: value.dictionary as [String : Any])
            completion(orderModel, nil)
        }
    }
    
    func cancelOCOOrder(symbol: String, orderListId: Int? = nil, listClientOrderId: String? = nil, newClientOrderId: String? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping (_ result: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.symbol: symbol,
                      Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let orderListId = orderListId { params[Keys.parameterKeys.orderListId] = orderListId }
        if let listClientOrderId = listClientOrderId { params[Keys.parameterKeys.listClientOrderId] = listClientOrderId }
        if let newClientOrderId = newClientOrderId { params[Keys.parameterKeys.newClientOrderId] = newClientOrderId }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.cancelOco, type: .mappableJsonType, method: .delete, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }

            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let orderModel = OrderResponseObject(JSON: value.dictionary as [String : Any])
            completion(orderModel, nil)

        }
    }
    
    func queryOCOOrder(orderListId: Int? = nil, origClientOrderId: String? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping (_ response: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let orderListId = orderListId { params[Keys.parameterKeys.orderListId] = orderListId }
        if let origClientOrderId = origClientOrderId { params[Keys.parameterKeys.origClientOrderId] = origClientOrderId }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.queryOco, type: .mappableJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let orderModel = OrderResponseObject(JSON: value.dictionary as [String : Any])
            completion(orderModel, nil)
        }
    }
    
    func fetchAllOCOOrders(limit: Int? = nil, fromId: UInt? = nil, startTime: TimeInterval? = nil, endTime: TimeInterval? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: [OrderResponseObject]?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let limit = limit { params[Keys.parameterKeys.limit] = limit }
        if let fromId = fromId { params[Keys.parameterKeys.fromId] = fromId }
        if let startTime = startTime { params[Keys.parameterKeys.startTime] = startTime }
        if let endTime = endTime { params[Keys.parameterKeys.endTime] = endTime }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.queryAllOcos, type: .arrayOfJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [OrderResponseObject]()
            for model in value.array {
                let orderModel = OrderResponseObject(JSON: model as [String : Any])
                modelsArray.append(orderModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
    
    func fetchOpenOCOOrders(recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: [OrderResponseObject]?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.queryOpenOcos, type: .arrayOfJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [OrderResponseObject]()
            for model in value.array {
                let orderModel = OrderResponseObject(JSON: model as [String : Any])
                modelsArray.append(orderModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
    
    func fetchAccountInformation(recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ accountInfo: AccountInformation?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.accountInformation, type: .mappableJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let accountInfo = AccountInformation(JSON: value.dictionary as [String : Any])
            completion(accountInfo, nil)
        }
    }
    
    func fetchAccountTradeList(symbol: String, limit: Int? = nil, fromId: UInt? = nil, startTime: TimeInterval? = nil, endTime: TimeInterval? = nil, recvWindow: Int? = nil, timestamp: TimeInterval, completion: @escaping(_ orderBook: [AccountOrderDetailObject]?, _ error: ApiError?) -> Swift.Void) {
        
        var params = [Keys.parameterKeys.symbol: symbol,
                      Keys.parameterKeys.timestamp: "\(timestamp)".components(separatedBy: ".").first!] as [String : Any]
        
        if let limit = limit { params[Keys.parameterKeys.limit] = limit }
        if let fromId = fromId { params[Keys.parameterKeys.fromId] = fromId }
        if let startTime = startTime { params[Keys.parameterKeys.startTime] = startTime }
        if let endTime = endTime { params[Keys.parameterKeys.endTime] = endTime }
        if let recvWindow = recvWindow { params[Keys.parameterKeys.recvWindow] = recvWindow }
        
        self.request(endpoint: Keys.endPoints.accountTradeList, type: .arrayOfJsonType, method: .get, body: nil, parameters: params, embedApiKey: true, embedSignature: true, headers: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [AccountOrderDetailObject]()
            for model in value.array {
                let orderModel = AccountOrderDetailObject(JSON: model as [String : Any])
                modelsArray.append(orderModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
}
