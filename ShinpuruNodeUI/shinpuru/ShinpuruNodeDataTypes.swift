//
//  ShinpuruNodeDataTypes.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

/// Node value object

class SNNode: Equatable, Hashable
{
    let uuid  = NSUUID()
    
    var inputSlots: Int = 0
    var inputs: [SNNode]?
    var position: CGPoint
    var name: String
    
    required init(name: String, position: CGPoint)
    {
        self.name = name
        self.position = position
    }
    
    var hashValue: Int
    {
        return uuid.hashValue
    }
}

func == (lhs: SNNode, rhs: SNNode) -> Bool
{
    return lhs.uuid.isEqual(rhs.uuid)
}

/// SNView delegate protocol

protocol SNDelegate: NSObjectProtocol
{
    func itemRenderer(view view:SNView, node: SNNode) -> SNItemRenderer
    
    func inputRowRenderer(view view:SNView, node: SNNode, index: Int) -> SNInputRowRenderer
    
    func nodeMoved(view view: SNView, node: SNNode)
}

/// Base class for node item renderer

class SNItemRenderer: UIView
{
    var node: SNNode
    
    required init(node: SNNode)
    {
        self.node = node
        
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Base class for input row renderer

class SNInputRowRenderer: UIView
{
    var index: Int
    var node: SNNode
    
    required init(index: Int, node: SNNode)
    {
        self.index = index
        self.node = node
        
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}





