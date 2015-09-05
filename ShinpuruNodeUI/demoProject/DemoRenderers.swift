//
//  DemoRenderers.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 04/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

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
        if let value = (node as? DemoNode)?.value
        {
            switch value
            {
            case DemoNodeValue.Number(let floatValue):
                label.text = "\(floatValue)"
            default:
                label.text = "???"
            }
        }
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 100, height: 25)
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds.insetBy(dx: 2, dy: 0)
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        linePath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        
        if index == 0
        {
            linePath.moveToPoint(CGPoint(x: 0, y: 0))
            linePath.addLineToPoint(CGPoint(x: bounds.width, y: 0))
        }
        
        line.path = linePath.CGPath
    }
}

// ----

class DemoOutputRowRenderer: SNOutputRowRenderer
{
    let label = UILabel()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.darkGrayColor()
      
        addSubview(label)
        
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Right
        
        label.text = "Output"
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 100, height: 25)
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds.insetBy(dx: 2, dy: 0)
    }
}

// ----

class DemoRenderer: SNItemRenderer
{
    let label = UILabel()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blueColor()
        alpha = 0.75
        
        addSubview(label)
        
        label.textColor = UIColor.whiteColor()
        
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
        if let value = (node as? DemoNode)?.value
        {
            switch value
            {
            case DemoNodeValue.Number(let floatValue):
                label.text = "\(floatValue)"
            default:
                label.text = "???"
            }
        }
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 100, height: 75)
    }
}
