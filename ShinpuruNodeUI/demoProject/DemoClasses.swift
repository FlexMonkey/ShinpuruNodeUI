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
    {
        didSet
        {
            recalculate()
        }
    }
    
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
    
    override var inputSlots: Int
    {
        set
        {
            // ignore - we compute this from the type
        }
        get
        {
            return type.inputSlots
        }
    }
    
    func recalculate()
    {
        let floatValue: Float
        
        switch type
        {
        case .Add:
            floatValue = getInputValueAt(0).floatValue + getInputValueAt(1).floatValue + getInputValueAt(2).floatValue + getInputValueAt(3).floatValue
            
        case .Subtract:
            floatValue = getInputValueAt(0).floatValue - getInputValueAt(1).floatValue
            
        case .Multiply:
            floatValue = getInputValueAt(0).floatValue * getInputValueAt(1).floatValue
            
        case .Divide:
            floatValue = getInputValueAt(0).floatValue / getInputValueAt(1).floatValue
            
        case .Numeric:
            floatValue = value?.floatValue ?? Float(0)
        }
        
        if let inputs = inputs where inputs.count >= type.inputSlots
        {
            self.inputs = Array(inputs[0 ... type.inputSlots - 1])
        }
        
        value = DemoNodeValue.Number(floatValue)
    }
    
    func getInputValueAt(index: Int) -> DemoNodeValue
    {
        if inputs == nil || index >= inputs?.count || inputs?[index] == nil || inputs?[index] as? DemoNode == nil
        {
            return DemoNodeValue.Number(0)
        }
        else if let value = (inputs?[index] as! DemoNode).value
        {
            return value
        }
        else
        {
            return DemoNodeValue.Number(0)
        }
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
    
    var inputSlots: Int
    {
        switch self
        {
        case .Numeric:
            return 0
        case .Add:
            return 4
        case .Subtract, .Multiply, .Divide:
            return 2
        }
    }
    
    var isOperator: Bool
    {
        return DemoNodeType.operators.indexOf(self) != nil
    }
}

enum DemoNodeValue
{
    case Number(Float)

    var floatValue: Float
    {
        switch self
        {
        case .Number(let value):
            return value
        }
    }
}






