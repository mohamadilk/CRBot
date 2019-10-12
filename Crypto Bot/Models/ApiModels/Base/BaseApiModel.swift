//
//  BaseApiModel.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/3/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import ObjectMapper

public class BaseApiModel: Mappable
{
    public required init?(map: Map)
    {
    }
    
    public func mapping(map: Map)
    {
    }
    
    public required convenience init?()
    {
        self.init(map: Map(mappingType: .fromJSON, JSON: ["" : ""]))
    }
}
