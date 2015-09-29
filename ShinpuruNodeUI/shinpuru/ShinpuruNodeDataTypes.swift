//
//  ShinpuruNodeDataTypes.swift
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

/// Node value object

class SNNode: Equatable, Hashable
{
    let uuid  = NSUUID()
    
    var numInputSlots: Int = 0
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
    
    func isAscendant(node: SNNode) -> Bool // TO DO test long chain
    {
        guard let inputs = inputs else
        {
            return false
        }
        
        for inputNode in inputs
        {
            if inputNode == node
            {
                return true
            }
            else if inputNode != nil && inputNode!.isAscendant(node)
            {
                return true
            }
        }
        
        return false
    }
}

func == (lhs: SNNode, rhs: SNNode) -> Bool
{
    return lhs.uuid.isEqual(rhs.uuid)
}

/// Node Pair - used as a dictionary key in relationship curves layer

struct SNNodePair: Equatable, Hashable
{
    let sourceNode: SNNode
    let targetNode: SNNode
    let targetIndex: Int
    
    var hashValue: Int
    {
        return sourceNode.uuid.hashValue + targetNode.uuid.hashValue + targetIndex.hashValue
    }
}

func == (lhs: SNNodePair, rhs: SNNodePair) -> Bool
{
    return lhs.sourceNode == rhs.sourceNode && lhs.targetNode == rhs.targetNode && lhs.targetIndex == rhs.targetIndex
}

/// SNView delegate protocol

protocol SNDelegate: NSObjectProtocol
{
    func dataProviderForView(view: SNView) -> [SNNode]?
    
    func itemRendererForView(view: SNView, node: SNNode) -> SNItemRenderer
    
    func inputRowRendererForView(view: SNView, inputNode: SNNode?, parentNode: SNNode, index: Int) -> SNInputRowRenderer
    
    func outputRowRendererForView(view: SNView, node: SNNode) -> SNOutputRowRenderer
    
    func nodeSelectedInView(view: SNView, node: SNNode?)
    
    func nodeMovedInView(view: SNView, node: SNNode)
    
    func nodeCreatedInView(view: SNView, position: CGPoint)
    
    func nodeDeletedInView(view: SNView, node: SNNode)
    
    func relationshipToggledInView(view: SNView, sourceNode: SNNode, targetNode: SNNode, targetNodeInputIndex: Int)
    
    func defaultNodeSize(view: SNView) -> CGSize
    
    func nodesAreRelationshipCandidates(sourceNode: SNNode, targetNode: SNNode, targetIndex: Int) -> Bool 
}

/// Base class for node item renderer

class SNItemRenderer: UIView
{
    weak var node: SNNode?
    
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
    weak var node: SNNode?
    
    required init(node: SNNode)
    {
        self.node = node
        
        super.init(frame: CGRectZero)
    }
    
    func reload()
    {
        fatalError("reload() has not been implemented")
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
    
    unowned let parentNode: SNNode
    weak var inputNode: SNNode?
    
    required init(index: Int, inputNode: SNNode?, parentNode: SNNode)
    {
        self.index = index
        self.inputNode = inputNode
        self.parentNode = parentNode
        
        super.init(frame: CGRectZero)
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





