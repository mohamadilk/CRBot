//
//  BaseApiServices.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/3/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Arcane

enum FilterFailures: String {
    case PRICE_FILTER = "Filter failure: PRICE_FILTER"
    case PERCENT_PRICE = "Filter failure: PERCENT_PRICE"
    case LOT_SIZE = "Filter failure: LOT_SIZE"
    case MIN_NOTIONAL = "Filter failure: MIN_NOTIONAL"
    case ICEBERG_PARTS = "Filter failure: ICEBERG_PARTS"
    case MARKET_LOT_SIZE = "Filter failure: MARKET_LOT_SIZE"
    case MAX_NUM_ORDERS = "Filter failure: MAX_NUM_ORDERS"
    case MAX_ALGO_ORDERS = "Filter failure: MAX_ALGO_ORDERS"
    case MAX_NUM_ICEBERG_ORDERS = "Filter failure: MAX_NUM_ICEBERG_ORDERS"
    case EXCHANGE_MAX_NUM_ORDERS = "Filter failure: EXCHANGE_MAX_NUM_ORDERS"
    case EXCHANGE_MAX_ALGO_ORDERS = "Filter failure: EXCHANGE_MAX_ALGO_ORDERS"
}

public class BaseApiServices: NSObject
{
    
    internal var baseURL = "https://api.binance.com"
    internal var contentType = "application/x-www-form-urlencoded"
    internal var headerApiKey = "X-MBX-APIKEY"
    internal var signature = "signature"
    internal var secretKey: String?
    internal var apiKey: String?
    
    /*
     A Retry-After header is sent with a 418 or 429 responses and will give the number of seconds required to wait, in the case of a 418, to prevent a ban, or, in the case of a 429, until the ban is over.
     */
    var retryAfter = 0
    
    public func request(endpoint:String,
                                           type: responseType,
                                           method:Alamofire.HTTPMethod,
                                           body:Dictionary<String,Any>!,
                                           parameters:Dictionary<String,Any>!,
                                           embedApiKey: Bool? = false,
                                           embedSignature: Bool? = false,
                                           headers: [String: String]? = nil,
                                           completion: @escaping (Any?, ApiError?) -> Void)
    {
        
        apiKey = "86L8PtiePfoWX1qv5LE4IqZ0bFGjsgt8At9nQtJcP3Vb3JGkxuJQOMm2o7ODSaKT"
        secretKey = "0vIDlpqoKffgcNnKAV21BHzsqFKb46B9ii0ziRKYESn7wi3DFYr9gFdQqUmTLc9H"
        
        var requestHeaders : [String: String]? = nil
        if embedApiKey! {
            if let key = apiKey {
                requestHeaders = [headerApiKey: key]
            } else {
                let error = ApiError.createErrorWithErrorType(.provideKeys)
                error.statusCode = 1000
                completion(nil, error)
                return
            }
        }
        
        var finalUrl = URL(string: "\(baseURL)\(endpoint)")
        finalUrl = appendParametersIfNeeded(baseUrl: finalUrl!, params: parameters)

        let queryString = "\(finalUrl!)".components(separatedBy: "?").last
        
        if embedSignature! {
            if let key = secretKey {
                 // The query string concatenated with the request body
                let encodedKey = HMAC.SHA256(queryString!, key: key)
                finalUrl = finalUrl?.appending(signature, value: encodedKey)
            } else {
                let error = ApiError.createErrorWithErrorType(.provideKeys)
                error.statusCode = 1000
                completion(nil, error)
                return
            }
        }
        
        Alamofire.request( finalUrl!,
                           method: method,
                           parameters: body,
                           encoding: JSONEncoding.default,
                           headers: requestHeaders)
            .responseJSON { (apiResponse) in
//                print(apiResponse)
                var error: ApiError?
                let statusCode = apiResponse.response?.statusCode ?? 0
                
                switch statusCode {
                case 200...299:
                    break
                case 400:
                    if let result = apiResponse.result.value as? [String: Any] {
                        error = ApiError.createErrorWithErrorType(.unknown, description: self.errorDescriptionMessage(msg: result["msg"] as? String ?? "Something went wrong! please try again"))
                        error?.statusCode = result["code"] as? Int
                    }
                    break
                case 418:
                    error = ApiError.createErrorWithErrorType(.bannedIpAddress)
                    error?.statusCode = statusCode
                    break
                case 429:
                    error = ApiError.createErrorWithErrorType(.BreakingRateLimit)
                    error?.statusCode = statusCode
                    break
                case 400...499:
                    error = ApiError.createErrorWithErrorType(.malformed)
                    error?.statusCode = statusCode
                    break
                case 500...599:
                    error = ApiError.createErrorWithErrorType(.internalError)
                    error?.statusCode = statusCode
                    break
                default: break
                }
                
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                if let err = apiResponse.error {
                    error = ApiError()
                    error?.statusCode = 0
                    error?.description = err.localizedDescription
                    completion(nil, error)
                    return
                }
                
                var value: ServerResponse
                
                switch type {
                case .mappableJsonType:
                    value = mappableJson(dictionary: apiResponse.value as! Dictionary<String, Any>)
                    break
                case .arrayOfJsonType:
                    value = arrayOfJson(array: apiResponse.value as! Array<Dictionary<String, Any>>)
                    break
                case .arrayOfArrayType:
                    value = arrayOfArray(array: apiResponse.value as! Array<Array<Any>>)
                    break
                }
                completion(value, nil)
        }
    }
    
    public func set(apiKey: String, secretKey: String) {
        self.apiKey = apiKey
        self.secretKey = secretKey
    }
    
    private func appendParametersIfNeeded(baseUrl: URL, params: Dictionary<String,Any>?) -> URL {
        guard let parameters = params else { return baseUrl }
        
        var finalUrl = baseUrl
        for paramKey in parameters.keys {
            finalUrl = finalUrl.appending(paramKey, value: "\(parameters[paramKey]!)")
        }
        
        return finalUrl
    }
    
    private func errorDescriptionMessage(msg: String) -> String {
        switch msg {
        case FilterFailures.PRICE_FILTER.rawValue:
            return "Price is too high, too low, and/or not following the tick size rule for the symbol."
            
        case FilterFailures.PERCENT_PRICE.rawValue:
            return "Price is too high or too low from the average weighted price over the last minutes."
            
        case FilterFailures.LOT_SIZE.rawValue:
            return "Quantity is too high, too low, and/or not following the step size rule for the symbol."
            
        case FilterFailures.ICEBERG_PARTS.rawValue:
            return "ICEBERG order would break into too many parts; icebergQty is too small."
            
        case FilterFailures.MIN_NOTIONAL.rawValue:
            return "Price * Quantity is too low to be a valid order for the symbol."
            
        case FilterFailures.MARKET_LOT_SIZE.rawValue:
            return "MARKET order's quantity is too high, too low, and/or not following the step size rule for the symbol."
            
        case FilterFailures.MAX_NUM_ORDERS.rawValue:
            return "Account has too many open orders on the symbol."
            
        case FilterFailures.MAX_ALGO_ORDERS.rawValue:
            return "Account has too many open stop loss and/or take profit orders on the symbol."
            
        case FilterFailures.MAX_NUM_ICEBERG_ORDERS.rawValue:
            return "Account has too many open iceberg orders on the symbol."
            
        case FilterFailures.EXCHANGE_MAX_NUM_ORDERS.rawValue:
            return "Account has too many open orders on the exchange."
            
        case FilterFailures.EXCHANGE_MAX_ALGO_ORDERS.rawValue:
            return "Account has too many open stop loss and/or take profit orders on the exchange."
            
        default:
            break
        }
        return msg
    }
}

extension URL {
    
    func appending(_ queryItem: String, value: String?) -> URL {
        
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        
        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // Append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems
        
        // Returns the url from new url components
        return urlComponents.url!
    }
}

