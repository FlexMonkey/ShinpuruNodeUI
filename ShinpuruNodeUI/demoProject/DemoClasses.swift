//
//  DemoClasses.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

import UIKit

class DemoNode: SNNode
{
    var type: DemoNodeType = DemoNodeType.Numeric
    {
        didSet
        {
            if type.isOperator && inputs == nil
            {
                inputs = [DemoNode]()
            }
            else if !type.isOperator
            {
                inputs = nil
            }
        
            name = type.isOperator ? "operator" : "number"
            
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
        
        if let inputs = inputs where inputs.count >= type.inputSlots && type.inputSlots > 0
        {
            self.inputs = Array(inputs[0 ... type.inputSlots - 1])
        }
        
        value = DemoNodeValue.Number(floatValue)
    }
    
    func getInputValueAt(index: Int) -> DemoNodeValue
    {
        if inputs == nil || index >= inputs?.count || inputs?[index] == nil || inputs?[index]?.demoNode == nil
        {
            return DemoNodeValue.Number(0)
        }
        else if let value = inputs?[index]?.demoNode?.value
        {
            return value
        }
        else
        {
            return DemoNodeValue.Number(0)
        }
    }
}

extension SNNode
{
    var demoNode: DemoNode?
    {
        return self as? DemoNode
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
        return DemoNodeType.operators.contains(self)
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






