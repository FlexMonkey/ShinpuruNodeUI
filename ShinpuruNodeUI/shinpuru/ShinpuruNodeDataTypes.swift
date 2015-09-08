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
    var inputs: [SNNode?]?
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
    func dataProviderForView(view: SNView) -> [SNNode]?
    
    func itemRendererForView(view: SNView, node: SNNode) -> SNItemRenderer
    
    func inputRowRendererForView(view: SNView, node: SNNode, index: Int) -> SNInputRowRenderer
    
    func outputRowRendererForView(view: SNView, node: SNNode) -> SNOutputRowRenderer
    
    func nodeSelectedInView(view: SNView, node: SNNode?)
    
    func nodeMovedInView(view: SNView, node: SNNode)
    
    func nodeCreatedInView(view: SNView, position: CGPoint)
    
    func relationshipCreatedInView(view: SNView, sourceNode: SNNode, targetNode: SNNode, targetNodeInputIndex: Int)
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
    
    func reload()
    {
        fatalError("reload() has not been implemented")
    }
}

/// Base class for output row renderer

class SNOutputRowRenderer: UIView
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

class SNInputRowRenderer: SNOutputRowRenderer
{
    var index: Int
    
    required init(index: Int, node: SNNode)
    {
        self.index = index
        
        super.init(node: node)
    }

    func reload()
    {
        fatalError("reload() has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    required init(node: SNNode)
    {
        fatalError("init(node:) has not been implemented")
    }
}





