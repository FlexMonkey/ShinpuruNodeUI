//
//  DemoClasses.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

struct DemoNode: SNNode
{
    var inputs: [SNNode]?
    
    var position: CGPoint
    
    var name: String
    
    var type: DemoNodeType?
    
    var value: DemoNodeValue?
    
    init(name: String, position: CGPoint, value: DemoNodeValue)
    {
        self.name = name
        self.position = position
        
        self.value = value
    }
    
    init(name: String, position: CGPoint, type: DemoNodeType? = nil, inputs: [SNNode]? = nil)
    {
        self.name = name
        self.position = position
        
        self.type = type
        self.inputs = inputs
    }
}

enum DemoNodeType
{
    case Addition
    case Subtraction
}

enum DemoNodeValue
{
    case Number(Float)
    case Image(UIImage)
}
