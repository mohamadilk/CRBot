//
//  EnumValues.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

enum SymbolFilters: String {
    case PRICE_FILTER
    case PERCENT_PRICE
    case LOT_SIZE
    case MIN_NOTIONAL
    case MARKET_LOT_SIZE
    case MAX_NUM_ORDERS
    case MAX_NUM_ALGO_ORDERS
    case MAX_NUM_ICEBERG_ORDERS
}

enum ExchangeFilters: String {
    case EXCHANGE_MAX_NUM_ORDERS
    case EXCHANGE_MAX_NUM_ALGO_ORDERS
}

enum RateLimitType: String {
    case REQUEST_WEIGHT
    case ORDERS
    case RAW_REQUESTS
}

enum IntervalType: String {
    case SECOND
    case MINUTE
    case HOUR
    case DAY
}

enum SymbolStatus: String {
    case PRE_TRADING
    case TRADING
    case POST_TRADING
    case END_OF_DAY
    case HALT
    case AUCTION_MATCH
    case BREAK
}

enum SymbolType: String {
    case SPOT
}

enum OrderStatus: String {
    case NEW
    case PARTIALLY_FILLED
    case FILLED
    case CANCELED
    case PENDING_CANCEL //(currently unused)
    case REJECTED
    case EXPIRED
}

enum OCOStatus: String {
    case RESPONSE
    case EXEC_STARTED
    case ALL_DONE
}

enum OCOOrderStatus: String {
    case EXECUTING
    case ALL_DONE
    case REJECT
}

enum ContingencyType: String {
    case OCO
}

enum OrderTypes: String {
    case LIMIT
    case LIMIT_MAKER
    case MARKET
    case STOP_LOSS
    case STOP_LOSS_LIMIT
    case TAKE_PROFIT
    case TAKE_PROFIT_LIMIT
    case OCO
}

enum OrderSide: String {
    case BUY
    case SELL
}

enum TimeInForce: String {
    case GTC
    case IOC
    case FOK
}

enum newOrderRespType: String {
    case ACK
    case RESULT
    case FULL
}

enum CandlestickChartIntervals: String {
    case oneMin = "1m"
    case threeMin = "3m"
    case fiveMin = "5m"
    case fifteenMin = "15m"
    case thertyMin = "30m"
    case oneHour = "1h"
    case twoHour = "2h"
    case fourHour = "4h"
    case sixHour = "6h"
    case eightHour = "8h"
    case twelveHour = "12h"
    case oneDay = "1d"
    case threeDay = "3d"
    case oneWeek = "1w"
    case oneMonth = "1M"
}

enum ExecutionTypes: String {
    case NEW
    case CANCELED
    case REPLACED //(currently unused)
    case REJECTED
    case TRADE
    case EXPIRED

}

enum intervalLetter: String {
    case intervalLetter_S = "S"
    case intervalLetter_M = "M"
    case intervalLetter_H = "H"
    case intervalLetter_D = "D"
}
