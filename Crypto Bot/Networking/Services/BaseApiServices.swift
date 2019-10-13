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
    
    public func request<T: ServerResponse>(endpoint:String,
                                           type: responseType,
                                           method:Alamofire.HTTPMethod,
                                           body:Dictionary<String,Any>!,
                                           parameters:Dictionary<String,Any>!,
                                           embedApiKey: Bool? = false,
                                           embedSignature: Bool? = false,
                                           headers: [String: String]? = nil,
                                           response:@escaping (Result<T>) -> Void)
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
                response(.failure)
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
                response(.failure)
                return
            }
        }
        
        if endpoint == "/api/v3/order/oco" {
            print(finalUrl!)
//                    finalUrl = URL(string: "https://api.binance.com/api/v3/order/oco?quantity=0.14&recvWindow=60000&symbol=ETHBTC&stopLimitPrice=0.021750&side=SELL&price=0.021807&stopPrice=0.021740&stopLimitTimeInForce=GTC")

//https://api.binance.com/api/v3/order/oco?stopLimitPrice=0.021750&stopLimitTimeInForce=GTC&stopPrice=0.021740&quantity=6.38&symbol=ETHBTC&side=BUY&price=0.021800&timestamp=1570990521987&recvWindow=60000

//
//            finalUrl = finalUrl?.appending("timestamp", value: "\(Int(round(NSDate().timeIntervalSince1970 * 1000)))".components(separatedBy: ".").first!)
//
//            let encodedKey = HMAC.SHA256("\(finalUrl!)".components(separatedBy: "?").last!, key: secretKey!)
//            finalUrl = finalUrl?.appending(signature, value: encodedKey)
        }
        
        Alamofire.request( finalUrl!,
                           method: method,
                           parameters: body,
                           encoding: JSONEncoding.default,
                           headers: requestHeaders)
            .responseJSON { (apiResponse) in
                print(apiResponse)
                var error: ApiError?
                let statusCode = apiResponse.response?.statusCode ?? 0
                
                switch statusCode {
                case 200...299:
                    break
                case 400:
                    apiResponse.result.ifSuccess {
                        let result = apiResponse.result.value as! [String: Any]
                        error = ApiError.createErrorWithErrorType(.unknown, description: result["msg"] as? String)
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
                    response(.failure)
                    return
                }
                
                if let err = apiResponse.error {
                    error = ApiError()
                    error?.statusCode = 0
                    error?.description = err.localizedDescription
                    response(.failure)
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
                
                if let value = value as? T { response(.success(value: value)) }
                else { response(.failure) }
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

