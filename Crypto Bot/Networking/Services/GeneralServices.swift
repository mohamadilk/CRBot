//
//  GeneralServices.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

fileprivate struct Keys
{
    fileprivate struct endPoints {
        fileprivate static let testConnectivity = "/api/v3/ping"
        fileprivate static let checkServerTime = "/api/v3/time"
        fileprivate static let exchangeInformation = "/api/v3/exchangeInfo" //1
        
    }
    
    fileprivate struct parameterKeys {
        fileprivate static let symbol = "symbol"
        fileprivate static let limit = "limit"
    }
    
    fileprivate struct jsonKeys {
        fileprivate static let serverTime = "serverTime"
    }
}

class GeneralServices: BaseApiServices {
    
    static let shared = GeneralServices()
    
    func testConnectivity() {
        self.request(endpoint: Keys.endPoints.testConnectivity, type: .mappableJsonType, method: .get, body: nil, parameters: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
//                completion(nil, error)
                return
            }
            
//            guard let value = result as? mappableJson else {
//                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
//                completion(nil, error)
//                return
//            }
            
            print("CONNECTED...")
        }
    }
    
    func checkServerTime(completion: @escaping (_ timeInterval: TimeInterval?, _ error: ApiError?) -> Swift.Void) {
        self.request(endpoint: Keys.endPoints.checkServerTime, type: .mappableJsonType, method: .get, body: nil, parameters: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            completion(value.dictionary[Keys.jsonKeys.serverTime] as? TimeInterval, nil)
        }
    }
    
    func exchangeInformation(completion: @escaping (_ info: ExchangeInformationResponse?, _ error: ApiError?) -> Swift.Void) {
        self.request(endpoint: Keys.endPoints.exchangeInformation, type: .mappableJsonType, method: .get, body: nil, parameters: nil) { (result: Any?, error: ApiError?) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            let excInfo = ExchangeInformationResponse(JSON: value.dictionary as [String : Any])
            completion(excInfo, nil)
        }
    }
}
