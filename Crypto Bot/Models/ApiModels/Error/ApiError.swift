//
//  ApiError.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/3/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import ObjectMapper
public enum ApiErrorTypes: Int
{
    case unknown
    case malformed
    case BreakingRateLimit
    case bannedIpAddress
    case internalError
    case provideKeys
}

public class ApiError: BaseApiModel, Error
{
    public var errorType: ApiErrorTypes?
    public var statusCode: Int?
    public var serverError: Error?
    public var description: String = "Unknown Error!"
    
    public var localizedDescription: String {
        return description
        
    }
    
    public static func createErrorWithErrorType(_ errorType: ApiErrorTypes, description: String? = nil) -> ApiError
    {
        let error = ApiError()
        error?.errorType = errorType
        switch errorType {
        case .malformed:
            error?.description = "Json parsing error"
            break
        case .BreakingRateLimit:
            error?.description = "breaking a request rate limit"
            break
            case .bannedIpAddress:
            error?.description = "IP has been auto-banned for continuing to send requests after receiving 429 codes"
            break
            case .internalError:
            error?.description = "internal error; the issue is on Binance's side"
            break
        case .provideKeys:
            error?.description = "Please provide Key and(or) Secret key first!"
            break
        default:
            error?.description = description ?? "Functional Error!"
            break
        }
        return error!
    }
}
