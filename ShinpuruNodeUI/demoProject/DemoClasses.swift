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
    // the function or operator of the node
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
        
            name = type.rawValue
            
            recalculate()
        }
    }
    
    var value: DemoNodeValue?

    required init(name: String, position: CGPoint)
    {
        super.init(name: type.rawValue, position: position)
    }
    
    init(name: String, position: CGPoint, value: DemoNodeValue)
    {
        super.init(name: type.rawValue, position: position)
        
        self.value = value
    }
    
    init(name: String, position: CGPoint, type: DemoNodeType = DemoNodeType.Numeric, inputs: [SNNode?]? = nil)
    {
        super.init(name: type.rawValue, position: position)
        
        self.type = type
        self.inputs = inputs
    }
    
    override var numInputSlots: Int
    {
        set
        {
            // ignore - we compute this from the type
        }
        get
        {
            return type.numInputSlots
        }
    }
    
    var outputType: DemoNodeValue
    {
        switch type
        {
        case .Add, .Subtract, .Multiply, .Divide, .Numeric:
            return DemoNodeValue.numberType()

        case .Color, .ColorAdjust:
            return DemoNodeValue.colorType()
        }
    }
    
    func recalculate()
    {
        switch type
        {
        case .Add:
            value = DemoNodeValue.number(getInputValueAt(0).floatValue +
                getInputValueAt(1).floatValue +
                getInputValueAt(2).floatValue)
            
        case .Subtract:
            value = DemoNodeValue.number(getInputValueAt(0).floatValue - getInputValueAt(1).floatValue)
            
        case .Multiply:
            value = DemoNodeValue.number(getInputValueAt(0).floatValue * getInputValueAt(1).floatValue)
            
        case .Divide:
            value = DemoNodeValue.number(getInputValueAt(0).floatValue / getInputValueAt(1).floatValue)
            
        case .Numeric:
            value = DemoNodeValue.number(value?.floatValue ?? Float(0))
            
        case .Color:
            let red = getInputValueAt(0).floatValue / 255
            let green = getInputValueAt(1).floatValue / 255
            let blue = getInputValueAt(2).floatValue / 255
            
            let colorValue = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
            
            value = DemoNodeValue.color(colorValue)
            
        case .ColorAdjust:
            let inputColor = getInputValueAt(0).colorValue
            let inputMultiplier = CGFloat(getInputValueAt(1).floatValue / 255)
            
            value = DemoNodeValue.color(inputColor.multiply(inputMultiplier))
        }
        
        if let inputs = inputs
        {
            if inputs.count >= type.numInputSlots && type.numInputSlots > 0
            {
                self.inputs = Array(inputs[0 ... type.numInputSlots - 1])
            }
            
            for (idx, input) in self.inputs!.enumerated() where input?.demoNode != nil
            {
                if !DemoModel.nodesAreRelationshipCandidates(input!.demoNode!, targetNode: self, targetIndex: idx)
                {
                    self.inputs?[idx] = nil
                }
            }
        }
    }
    
    func getInputValueAt(_ index: Int) -> DemoNodeValue
    {
        if inputs == nil || index >= inputs?.count || inputs?[index] == nil || inputs?[index]?.demoNode == nil
        {
            return DemoNodeValue.number(0)
        }
        else if let value = inputs?[index]?.demoNode?.value
        {
            return value
        }
        else
        {
            return DemoNodeValue.number(0)
        }
    }
    
    deinit
    {
        print("** DemoNode deinit")
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
    
    case Color
    case ColorAdjust
    
    static let operators = [Add, Subtract, Multiply, Divide, Color, ColorAdjust]
    
    var inputSlots: [DemoNodeInputSlot]
    {
        switch self
        {
        case .Numeric:
            return []
            
        case .Add:
            return [DemoNodeInputSlot(label: "x", type: DemoNodeValue.numberType()),
                DemoNodeInputSlot(label: "y", type: DemoNodeValue.numberType()),
                DemoNodeInputSlot(label: "z", type: DemoNodeValue.numberType())]
        
        case .Subtract, .Multiply, .Divide:
            return [DemoNodeInputSlot(label: "x", type: DemoNodeValue.numberType()),
                DemoNodeInputSlot(label: "y", type: DemoNodeValue.numberType())]
        
        case .Color:
            return [DemoNodeInputSlot(label: "red", type: DemoNodeValue.numberType()),
                DemoNodeInputSlot(label: "green", type: DemoNodeValue.numberType()),
                DemoNodeInputSlot(label: "blue", type: DemoNodeValue.numberType())]
            
        case .ColorAdjust:
            return [DemoNodeInputSlot(label: "color", type: DemoNodeValue.colorType()),
                DemoNodeInputSlot(label: "multiplier", type: DemoNodeValue.numberType())]
        }
    }
    
    var numInputSlots: Int
    {
        return inputSlots.count
    }
    
    var isOperator: Bool
    {
        return DemoNodeType.operators.contains(self)
    }
}

struct DemoNodeInputSlot
{
    let label: String
    let type: DemoNodeValue
}

enum DemoNodeValue
{
    case number(Float?)
    case color(UIColor?)

    // empty values for type matching
    
    static func numberType() -> DemoNodeValue
    {
        return DemoNodeValue.number(nil)
    }
    
    static func colorType() -> DemoNodeValue
    {
        return DemoNodeValue.color(nil)
    }
    
    // get non-optional associated value
    
    var floatValue: Float
    {
        switch self
        {
        case .number(let value):
            return value ?? 0
        default:
            return 0
        }
    }
    
    var colorValue: UIColor
    {
        switch self
        {
        case .color(let value):
            return value ?? UIColor.white
            
        default:
            return UIColor.white
        }
    }
    
    // return the type name
    
    var typeName: String
    {
        switch self
        {
        case .number:
            return SNNumberTypeName
        case .color:
            return SNColorTypeName
        }
    }
}

let SNNumberTypeName = "Number"
let SNColorTypeName = "Color"






