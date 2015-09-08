//
//  DemoRenderers.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 04/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

let DemoWidgetWidth = 100

class DemoInputRowRenderer: SNInputRowRenderer
{
    let label = UILabel()
    let line = CAShapeLayer()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.lightGrayColor()

        addSubview(label)
        layer.addSublayer(line)
  
        line.strokeColor = UIColor.whiteColor().CGColor
        line.lineWidth = 2
    }
    
    override var node: SNNode?
    {
        didSet
        {
            super.node = node
            
            updateLabel()
        }
    }
    
    override func reload()
    {
        updateLabel()
    }
    
    func updateLabel()
    {
        if let value = node?.demoNode?.value, name = node?.name
        {
            switch value
            {
            case DemoNodeValue.Number(let floatValue):
                label.text = "\(name) \(floatValue)"
            }
        }
        else
        {
           label.text = ""
        }
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: 25)
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds.insetBy(dx: 2, dy: 0)
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        linePath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        
        if index == 0
        {
            linePath.moveToPoint(CGPoint(x: 0, y: 1))
            linePath.addLineToPoint(CGPoint(x: bounds.width, y: 1))
        }
        
        line.path = linePath.CGPath
    }
}

// ----

class DemoOutputRowRenderer: SNOutputRowRenderer
{
    let label = UILabel()
    let line = CAShapeLayer()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.darkGrayColor()
      
        addSubview(label)
        layer.addSublayer(line)
        
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Right
        
        line.strokeColor = UIColor.whiteColor().CGColor
        line.lineWidth = 1
        
        label.text = "Output"
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: 25)
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds.insetBy(dx: 2, dy: 0)
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPoint(x: 0, y: 0))
        linePath.addLineToPoint(CGPoint(x: bounds.width, y: 0))
  
        line.path = linePath.CGPath
    }
}

// ----

class DemoRenderer: SNItemRenderer
{
    let label = UILabel()
    
    override func didMoveToSuperview()
    {
        addSubview(label)
        
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.Center
        
        updateLabel()
    }
    
    override var node: SNNode
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
        if let value = node.demoNode?.value, type = node.demoNode?.type
        {
            backgroundColor = type.isOperator ? UIColor.blueColor() : UIColor.redColor()
            
            switch value
            {
            case DemoNodeValue.Number(let floatValue):
                label.text = "\(type) \n\(floatValue)"
            }
        }
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: 75)
    }
}
