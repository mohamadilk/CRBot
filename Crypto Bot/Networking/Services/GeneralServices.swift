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
        fileprivate static let testConnectivity = "/api/v1/ping"
        fileprivate static let checkServerTime = "/api/v1/time"
        fileprivate static let exchangeInformation = "/api/v1/exchangeInfo"
        
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
        self.request(endpoint: Keys.endPoints.testConnectivity, type: .mappableJsonType, method: .get, body: nil, parameters: nil) { (result :Result<mappableJson>) in
            guard let _ = result.value else {
                return
            }
            print("CONNECTED...")
        }
    }
    
    func checkServerTime(response:@escaping (_ timeInterval: TimeInterval?, _ error: ApiError?) -> Swift.Void) {
        self.request(endpoint: Keys.endPoints.checkServerTime, type: .mappableJsonType, method: .get, body: nil, parameters: nil) { (result: Result<mappableJson>) in
            
            guard let value = result.value else {
                response(nil, nil)
                return
            }
            response(value.dictionary[Keys.jsonKeys.serverTime] as? TimeInterval, nil)
        }
    }
    
    func exchangeInformation(response:@escaping (_ info: ExchangeInformationresponse?, _ error: ApiError?) -> Swift.Void) {
        self.request(endpoint: Keys.endPoints.exchangeInformation, type: .mappableJsonType, method: .get, body: nil, parameters: nil) { (result: Result<mappableJson>) in
            
            guard let value = result.value else {
                response(nil, nil)
                return
            }
            let excInfo = ExchangeInformationresponse(JSON: value.dictionary as [String : Any])
            response(excInfo, nil)
        }
    }
}
