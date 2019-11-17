//
//  MarketDataServices.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

fileprivate struct Keys
{
    fileprivate struct endPoints {
        fileprivate static let orderBook = "/api/v1/depth"
        fileprivate static let trades = "/api/v1/trades"
        fileprivate static let historicalTrades = "/api/v1/historicalTrades"
        fileprivate static let aggTrades = "/api/v1/aggTrades"
        fileprivate static let klines = "/api/v1/klines"
        fileprivate static let avgPrice = "/api/v3/avgPrice"
        fileprivate static let oneDayTicker = "/api/v1/ticker/24hr"
        fileprivate static let SymbolPriceTicker = "/api/v3/ticker/price"
        fileprivate static let SymbolOrderBookTicker = "/api/v3/ticker/bookTicker"
    }
    
    fileprivate struct parameterKeys {
        fileprivate static let symbol = "symbol"
        fileprivate static let limit = "limit"
        fileprivate static let fromId = "fromId"
        fileprivate static let startTime = "startTime"
        fileprivate static let endTime = "endTime"
        fileprivate static let interval = "interval"
    }
}

class MarketDataServices: BaseApiServices {
    
    static let shared = MarketDataServices()
    
    func fetchOrderBook(symbol: String, limit: Int? = nil, completion: @escaping(_ orderBook: OrderBookObject?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.orderBook, type: .mappableJsonType, method: .get, body: nil, parameters: [Keys.parameterKeys.symbol:symbol, Keys.parameterKeys.limit: limit ?? 100]) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let responseObject = OrderBookResponseObject(JSON: value.dictionary as [String : Any])
            var finalResponse = OrderBookObject(lastUpdateId: responseObject?.lastUpdateId)
            
            for bid in responseObject!.bids! {
                let bidAsk = BidAskObject(price: bid[0], quantity: bid[1])
                finalResponse.bids.append(bidAsk)
            }
            
            for ask in responseObject!.asks! {
                let bidAsk = BidAskObject(price: ask[0], quantity: ask[1])
                finalResponse.asks.append(bidAsk)
            }
            
            completion(finalResponse, nil)
        }
    }
    
    func RecentTradesList(symbol: String, limit: Int? = nil, completion: @escaping(_ orderBook: [TradeObject]?, _ error: ApiError?) -> Void) {
        self.request(endpoint: Keys.endPoints.trades, type: .arrayOfJsonType, method: .get, body: nil, parameters: [Keys.parameterKeys.symbol:symbol, Keys.parameterKeys.limit: limit ?? 500]) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var tradesArray = [TradeObject]()
            for model in value.array {
                let tradesReponse = TradeObject(JSON: model as [String : Any])
                tradesArray.append(tradesReponse!)
            }
            completion(tradesArray, nil)
        }
    }
    
    func fetchHistoricalTrades(symbol: String, limit: Int? = nil, fromId: UInt? = nil, completion: @escaping(_ orderBook: [TradeObject]?, _ error: ApiError?) -> Swift.Void) {
        var params = [Keys.parameterKeys.symbol:symbol, Keys.parameterKeys.limit: limit ?? 500] as [String : Any]
        if let from = fromId { params[Keys.parameterKeys.fromId] = from }

        self.request(endpoint: Keys.endPoints.trades, type: .arrayOfJsonType, method: .get, body: nil, parameters: params) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var tradesArray = [TradeObject]()
            for model in value.array {
                let tradesReponse = TradeObject(JSON: model as [String : Any])
                tradesArray.append(tradesReponse!)
            }
            completion(tradesArray, nil)
        }
    }
    
    func fetchAggregateTradesList(symbol: String, limit: Int? = nil, fromId: UInt? = nil, startTime: UInt? = nil, endTime: UInt? = nil, completion: @escaping(_ orderBook: [AggregateTradeObject]?, _ error: ApiError?) -> Swift.Void) {
        var params = [Keys.parameterKeys.symbol:symbol, Keys.parameterKeys.limit: limit ?? 500] as [String : Any]
        if let start = startTime { params[Keys.parameterKeys.startTime] = start }
        if let end = endTime { params[Keys.parameterKeys.endTime] = end }
        if let from = fromId { params[Keys.parameterKeys.fromId] = from }
        
        self.request(endpoint: Keys.endPoints.aggTrades, type: .arrayOfJsonType, method: .get, body: nil, parameters: params) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var tradesArray = [AggregateTradeObject]()
            for model in value.array {
                let tradesReponse = AggregateTradeObject(JSON: model as [String : Any])
                tradesArray.append(tradesReponse!)
            }
            completion(tradesArray, nil)
        }
    }
    
    func fetchCandlestickData(symbol: String, interval: String, limit: Int? = nil, startTime: UInt? = nil, endTime: UInt? = nil, completion: @escaping(_ orderBook: [CandleObject]?, _ error: ApiError?) -> Swift.Void) {
        var params = [Keys.parameterKeys.symbol: symbol, Keys.parameterKeys.limit: limit ?? 500, Keys.parameterKeys.interval: interval] as [String : Any]
        if let start = startTime { params[Keys.parameterKeys.startTime] = start }
        if let end = endTime { params[Keys.parameterKeys.endTime] = end }
        
//        self.request(endpoint: Keys.endPoints.klines, type: .arrayOfArrayType, method: .get, body: nil, parameters: params) { (result: Any?, error: ApiError?) in
//
//            if error != nil {
//                completion(nil, error)
//                return
//            }
//
//            guard let value = result as? arrayOfJson else {
//                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
//                completion(nil, error)
//                return
//            }
//
//            var candlesArray = [CandleObject]()
//            for model in value.array {
//
//                let candle = CandleObject(openTime: (model[0] as! TimeInterval), open: (model[1] as! String), high: (model[2] as! String), low: (model[3] as! String), close: (model[4] as! String), volume: (model[5] as! String), closeTime: (model[6] as! TimeInterval), quoteAssetVolume: (model[7] as! String), numberOfTrades: (model[8] as! Int), takerBuyBaseAssetVolume: (model[9] as! String), takerBuyquoteAssetVolume: (model[10] as! String), ignore: (model[11] as! String))
//                candlesArray.append(candle)
//            }
//            completion(candlesArray, nil)
//        }
    }
    
    func fetchCurrentAvaragePrice(symbol: String, completion: @escaping(_ orderBook: AvaragePriceObject?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.avgPrice, type: .mappableJsonType, method: .get, body: nil, parameters: [Keys.parameterKeys.symbol:symbol]) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let priceModel = AvaragePriceObject(JSON: value.dictionary as [String : Any])
            completion(priceModel, nil)
        }
    }
    
    func fetchOneDayTickerPriceChangeStatistics(symbol: String, completion: @escaping(_ orderBook: OneDayTickerPriceChangeObject?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.oneDayTicker, type: .mappableJsonType, method: .get, body: nil, parameters: [Keys.parameterKeys.symbol:symbol]) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let priceModel = OneDayTickerPriceChangeObject(JSON: value.dictionary as [String : Any])
            completion(priceModel, nil)
        }
    }
    
    func fetchOneDayTickerPriceChangeStatistics(completion: @escaping(_ orderBook: [OneDayTickerPriceChangeObject]?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.oneDayTicker, type: .arrayOfJsonType, method: .get, body: nil, parameters: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [OneDayTickerPriceChangeObject]()
            for model in value.array {
                let priceModel = OneDayTickerPriceChangeObject(JSON: model as [String : Any])
                modelsArray.append(priceModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
    
    
    func fetchSymbolPriceTicker(symbol: String, completion: @escaping(_ orderBook: SymbolPriceObject?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.SymbolPriceTicker, type: .mappableJsonType, method: .get, body: nil, parameters: [Keys.parameterKeys.symbol:symbol]) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let priceModel = SymbolPriceObject(JSON: value.dictionary as [String : Any])
            completion(priceModel, nil)
        }
    }
    
    func fetchSymbolPriceTicker(completion: @escaping(_ orderBook: [SymbolPriceObject]?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.SymbolPriceTicker, type: .arrayOfJsonType, method: .get, body: nil, parameters: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [SymbolPriceObject]()
            for model in value.array {
                let priceModel = SymbolPriceObject(JSON: model as [String : Any])
                modelsArray.append(priceModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
    
    func fetchSymbolOrderBookTicker(symbol: String, completion: @escaping(_ orderBook: SymbolOrderBookObject?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.SymbolOrderBookTicker, type: .mappableJsonType, method: .get, body: nil, parameters: [Keys.parameterKeys.symbol:symbol]) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let priceModel = SymbolOrderBookObject(JSON: value.dictionary as [String : Any])
            completion(priceModel, nil)
        }
    }
    
    func fetchSymbolOrderBookTicker(completion: @escaping(_ orderBook: [SymbolOrderBookObject]?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.SymbolOrderBookTicker, type: .arrayOfJsonType, method: .get, body: nil, parameters: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? arrayOfJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            var modelsArray = [SymbolOrderBookObject]()
            for model in value.array {
                let priceModel = SymbolOrderBookObject(JSON: model as [String : Any])
                modelsArray.append(priceModel!)
            }
            
            completion(modelsArray, nil)
        }
    }
}
