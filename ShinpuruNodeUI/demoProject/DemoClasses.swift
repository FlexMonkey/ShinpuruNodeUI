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
    var type: DemoNodeType?
    
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
    
    init(name: String, position: CGPoint, type: DemoNodeType? = nil, inputs: [SNNode]? = nil)
    {
        super.init(name: name, position: position)
        
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


class DemoRenderer: SNItemRenderer
{
    let label = UILabel()
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blueColor()
        alpha = 0.75
        
        addSubview(label)
        
        label.textColor = UIColor.whiteColor()
        
        print( (node as? DemoNode)?.value )
    }
    
    override var node: SNNode?
        {
        didSet
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



