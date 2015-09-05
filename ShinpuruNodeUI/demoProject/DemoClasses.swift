//
//  DemoClasses.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class DemoNode: SNNode
{
    var type: DemoNodeType = DemoNodeType.Numeric
    
    var value: DemoNodeValue?
    
    required init(name: String, position: CGPoint)
    {
        super.init(name: name, position: position)
    }
    
    init(name: String, position: CGPoint, value: DemoNodeValue)
    {
        super.init(name: name, position: position)
        
        self.value = value
    }
    
    init(name: String, position: CGPoint, type: DemoNodeType = DemoNodeType.Numeric, inputs: [SNNode?]? = nil)
    {
        super.init(name: name, position: position)
        
        self.type = type
        self.inputs = inputs
    }
    
    func recalculate()
    {
        print("recalculate", name, type)
        
        guard let inputs = inputs where DemoNodeType.operators.indexOf(type) != nil else
        {
            return
        }
        
        var val: Float = 0.0
        
        for inputNode in inputs
        {
            if let value = (inputNode as? DemoNode)?.value
            {
                switch value
                {
                case DemoNodeValue.Number(let floatValue):
                    val += floatValue
                }
            }
        }
        
        value = DemoNodeValue.Number(val)
    }
}

enum DemoNodeType: String
{
    case Numeric
    
    case Add
    case Subtract
    case Multiply
    case Divide
    
    static let operators = [Add, Subtract, Multiply, Divide]
}

enum DemoNodeValue
{
    case Number(Float)
}






