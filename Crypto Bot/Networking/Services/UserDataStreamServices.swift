//
//  UserDataStreamServices.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import Starscream

fileprivate struct Keys
{
    fileprivate struct endPoints {
        fileprivate static let userDataStream = "/api/v1/userDataStream"
    }
    
    fileprivate struct parameterKeys {
        fileprivate static let listenKey = "listenKey"
    }
}

protocol UserDataStreamServicesDelegate {
    
    func didReceiveExecutionReport(object: ExecutionReport)
    func didReceiveOutboundAccount(Info: OutboundAccountInfo)
    
}

class UserDataStreamServices: BaseApiServices {
    
    static let shared = UserDataStreamServices()
    var delegate: UserDataStreamServicesDelegate?
    var socket: WebSocket?
    
    // Start a new user data stream. The stream will close after 60 minutes unless a keepalive is sent.
    func startUserDataStream(completion: @escaping(_ listenKey: String?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.userDataStream, type: .mappableJsonType, method: .post, body: nil, parameters: nil, embedApiKey: true) { (result: Any?, error: ApiError?) in
           
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let value = result as? mappableJson else {
                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
                completion(nil, error)
                return
            }
            
            let key = value.dictionary[Keys.parameterKeys.listenKey]
            self.initializeWebSocket(listenKey: key as! String)
            completion(key as? String, nil)
        }
        
    }
    
    // Keepalive a user data stream to prevent a time out. User data streams will close after 60 minutes. It's recommended to send a ping about every 30 minutes.
    func keepAliveUserDataStream(listenKey: String) {
        
        self.request(endpoint: Keys.endPoints.userDataStream, type: .mappableJsonType, method: .put, body: nil, parameters: [Keys.parameterKeys.listenKey: listenKey], embedApiKey: true) { (result: Any?, error: ApiError?) in
           
            if error != nil {
//                completion(nil, error)
                return
            }
//
//            guard let value = result as? mappableJson else {
//                let error = ApiError.createErrorWithErrorType(.malformed, description: "Malformed Response Data")
//                completion(nil, error)
//                return
//            }
            print("Seuccessfuly sent kepp alive")
        }
    }
    
    // Close out a user data stream.
    func closeAliveUserDataStream(listenKey: String, completion: @escaping(_ success: Bool) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.userDataStream, type: .mappableJsonType, method: .delete, body: nil, parameters: [Keys.parameterKeys.listenKey: listenKey], embedApiKey: true) { (result: Any?, error: ApiError?) in

            if error != nil {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    func initializeWebSocket(listenKey: String) {
        
        socket = WebSocket(url: URL(string: "wss://stream.binance.com:9443/ws/\(listenKey)")!)
        socket?.delegate = self
        socket?.connect()

    }
}

extension UserDataStreamServices: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription ?? "")")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let data = text.data(using: .utf8)!
       do {
            if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
            {
                switch json["e"] as! String {
                case "outboundAccountPosition", "outboundAccountInfo":
                    if let update = OutboundAccountInfo(JSON: json as [String : Any]) {
                        delegate?.didReceiveOutboundAccount(Info: update)
                    }
                    break
                case "executionReport":
                    if let update = ExecutionReport(JSON: json as [String : Any]) {
                        delegate?.didReceiveExecutionReport(object: update)
                    }
                    break
                default:
                    break
                }
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data)")
    }
}
