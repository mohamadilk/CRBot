//
//  ServerResponseTypes.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

public protocol ServerResponse {}

struct mappableJson: ServerResponse {
    let dictionary: Dictionary<String, Any>
}

struct arrayOfJson: ServerResponse {
    let array: Array<Dictionary<String, Any>>
}

struct arrayOfArray: ServerResponse {
    let array: Array<Array<Any>>
}

public enum responseType {
    case mappableJsonType
    case arrayOfJsonType
    case arrayOfArrayType
}

public enum Result<T> {
    case success(value: T)
    case failure(value: T)
    
    var value: T? {
        switch self {
        case .success(let value): return value
        case .failure(let value): return value
        }
    }
}
