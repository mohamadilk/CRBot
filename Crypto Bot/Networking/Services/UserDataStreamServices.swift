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

class UserDataStreamServices: BaseApiServices {
    
    static let shared = UserDataStreamServices()
    var socket: WebSocket?
    
    // Start a new user data stream. The stream will close after 60 minutes unless a keepalive is sent.
    func startUserDataStream(response: @escaping(_ listenKey: String?, _ error: ApiError?) -> Swift.Void) {
        
        self.request(endpoint: Keys.endPoints.userDataStream, type: .mappableJsonType, method: .post, body: nil, parameters: nil, embedApiKey: true) { (result: Result<mappableJson>) in
            guard let value = result.value else {
                response(nil, nil)
                return
            }
            
            response(value.dictionary[Keys.parameterKeys.listenKey] as? String, nil)
        }
        
    }
    
    // Keepalive a user data stream to prevent a time out. User data streams will close after 60 minutes. It's recommended to send a ping about every 30 minutes.
    func keepAliveUserDataStream(listenKey: String) {
        
        self.request(endpoint: Keys.endPoints.userDataStream, type: .mappableJsonType, method: .put, body: nil, parameters: [Keys.parameterKeys.listenKey: listenKey], embedApiKey: true) { (result: Result<mappableJson>) in
            guard let _ = result.value else {
                // Show error
                return
            }
        }
    }
    
    // Close out a user data stream.
    func closeAliveUserDataStream(listenKey: String) {
        
        self.request(endpoint: Keys.endPoints.userDataStream, type: .mappableJsonType, method: .delete, body: nil, parameters: [Keys.parameterKeys.listenKey: listenKey], embedApiKey: true) { (result: Result<mappableJson>) in
            guard let _ = result.value else {
                // Show error
                return
            }
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
                    let update = outboundAccountInfo(JSON: json as [String : Any])
                    print(update!)
                    break
                case "executionReport":
                    let update = executionReport(JSON: json as [String : Any])
                    print(update!)
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
        print("got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data)")
    }
}
