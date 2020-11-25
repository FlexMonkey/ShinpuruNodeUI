//
//  DemoRenderers.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 04/09/2015.
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

let DemoWidgetWidth: CGFloat = 200

class DemoInputRowRenderer: SNInputRowRenderer
{
    let label = UILabel()
    let line = CAShapeLayer()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.lightGray

        addSubview(label)
        layer.addSublayer(line)
  
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 1
        
        if superview != nil
        {
            reload()
        }
    }
    
    override var inputNode: SNNode?
    {
        didSet
        {
            super.inputNode = inputNode
            
            updateLabel()
        }
    }
    
    override func reload()
    {
        updateLabel()
    }
    
    func updateLabel()
    {
        guard let demoNode = parentNode.demoNode, index < parentNode.demoNode?.type.inputSlots.count ?? 0 else
        {
            label.text = ""
            return
        }
        
        label.text = demoNode.type.inputSlots[index].label + ": "
        
        if let value = inputNode?.demoNode?.value
        {
            switch value
            {
            case DemoNodeValue.Number(let floatValue):
                label.text = label.text! + " \(floatValue!)"
                
            case DemoNodeValue.Color(let colorValue):
                label.text = label.text! + " " + colorValue!.getHex()
            }
            
        }
    }
    
    override var intrinsicContentSize: CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: SNNodeWidget.titleBarHeight)
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds.insetBy(dx: 5, dy: 0)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: bounds.height))
        linePath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        
        if index == 0
        {
            linePath.move(to: CGPoint(x: 0, y: 1))
            linePath.addLine(to: CGPoint(x: bounds.width, y: 1))
        }
        
        line.path = linePath.cgPath
    }
}

// ----

class DemoOutputRowRenderer: SNOutputRowRenderer
{
    let label = UILabel()
    let line = CAShapeLayer()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.darkGray
      
        addSubview(label)
        layer.addSublayer(line)
        
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.right
        
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 1
        
        if superview != nil
        {
            reload()
        }
    }
    
    override var intrinsicContentSize: CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: SNNodeWidget.titleBarHeight)
    }
    
    override func reload()
    {
        updateLabel()
    }
    
    func updateLabel()
    {
        label.text = node?.demoNode?.outputType.typeName
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds.insetBy(dx: 5, dy: 0)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: bounds.width, y: 0))
  
        line.path = linePath.cgPath
    }
}

// ----

class DemoRenderer: SNItemRenderer
{
    let label = UILabel()
    let line = CAShapeLayer()
    let colorSwatch = UIView()
    
    override func didMoveToSuperview()
    {
        addSubview(colorSwatch)
        addSubview(label)
        layer.addSublayer(line)
        
        colorSwatch.layer.borderColor = UIColor.black.cgColor
        colorSwatch.layer.borderWidth = 1
        
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 1
        
        if superview != nil
        {
            reload()
        }
    }
    
    override var node: SNNode?
    {
        didSet
        {
            updateLabel()
        }
    }
    
    override func reload()
    {
        updateLabel()
    }
    
    func updateLabel()
    {
        if let value = node?.demoNode?.value, let type = node?.demoNode?.type
        {
            switch value
            {
            case DemoNodeValue.Number(let floatValue):
                label.text = "\(type) \n\(floatValue)"
                backgroundColor = type.isOperator ? UIColor.blue : UIColor.red
                colorSwatch.alpha = 0
                label.frame = bounds
                
            case DemoNodeValue.Color(let colorValue):
                label.text = colorValue?.getHex()
                backgroundColor = UIColor.purple
                colorSwatch.alpha = 1
                colorSwatch.backgroundColor = colorValue
                
                label.frame = CGRect(x: 0,
                                     y: bounds.height - label.intrinsicContentSize.height - 5,
                    width: bounds.width,
                    height: label.intrinsicContentSize.height)
            }
        }
        else
        {
            // TOODO - tidy this up
            backgroundColor = node?.demoNode?.type == DemoNodeType.Color || node?.demoNode?.type == DemoNodeType.ColorAdjust
                ? UIColor.purple
                : UIColor.blue
            
            colorSwatch.alpha = 0
        }
    }
    
    override func layoutSubviews()
    {
        updateLabel()
        
        colorSwatch.frame = bounds.insetBy(dx: 40, dy: 40)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: bounds.width, y: 0))
        
        line.path = linePath.cgPath
    }
    
    override var intrinsicContentSize: CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: DemoWidgetWidth)
    }
}
