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
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.lightGrayColor()
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
        
        addSubview(label)
        
        label.text = "\(index) Input Row!"
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 100, height: 20)
    }
    
    override func layoutSubviews()
    {
        label.frame = bounds
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
