//
//  DemoModel.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 07/09/2015.
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

struct DemoModel
{
    var nodes: [DemoNode]
    
    init() 
    {
        let one = DemoNode(name: "One", position: CGPoint(x: 210, y: 10), value: DemoNodeValue.Number(1))
        let two = DemoNode(name: "Two", position: CGPoint(x: 220, y: 350), value: DemoNodeValue.Number(2))
        let add = DemoNode(name: "Add", position: CGPoint(x: 570, y: 170), type: DemoNodeType.Add, inputs: [one, two, one])
        
        nodes = [one, two, add]
        
        updateDescendantNodes(one)
        updateDescendantNodes(two)
    }
    
    mutating func toggleRelationship(sourceNode: DemoNode, targetNode: DemoNode, targetIndex: Int) -> [DemoNode]
    {
        if targetNode.inputs == nil
        {
            targetNode.inputs = [DemoNode]()
        }
        
        if targetIndex >= targetNode.inputs?.count
        {
            for _ in 0 ... targetIndex - targetNode.inputs!.count
            {
                targetNode.inputs?.append(nil)
            }
        }
        
        if targetNode.inputs![targetIndex] == sourceNode
        {
            targetNode.inputs![targetIndex] = nil
            
            return updateDescendantNodes(sourceNode.demoNode!, forceNode: targetNode.demoNode!)
        }
        else
        {
            targetNode.inputs![targetIndex] = sourceNode
            
            return updateDescendantNodes(sourceNode.demoNode!)
        }
    }
    
    mutating func deleteNode(deletedNode: DemoNode) -> [DemoNode]
    {
        var updatedNodes = [DemoNode]()
        
        for node in nodes where node.inputs != nil && node.inputs!.contains({$0 == deletedNode})
        {
            for (idx, inputNode) in node.inputs!.enumerate() where inputNode == deletedNode
            {
                node.inputs?[idx] = nil
                
                node.recalculate()
                
                updatedNodes.appendContentsOf(updateDescendantNodes(node))
            }
        }
        
        if let deletedNodeIndex = nodes.indexOf(deletedNode)
        {
            nodes.removeAtIndex(deletedNodeIndex)
        }
        
        return updatedNodes
    }
    
    mutating func addNodeAt(position: CGPoint) -> DemoNode
    {
        let newNode = DemoNode(name: "New!", position: position, value: DemoNodeValue.Number(1))
        
        nodes.append(newNode)
        
        return newNode
    }
    
    func updateDescendantNodes(sourceNode: DemoNode, forceNode: DemoNode? = nil) -> [DemoNode]
    {
        var updatedDatedNodes = [[sourceNode]]
        
        for targetNode in nodes where targetNode != sourceNode
        {
            if let inputs = targetNode.inputs,
                targetNode = targetNode.demoNode where inputs.contains({$0 == sourceNode}) || targetNode == forceNode
            {
                targetNode.recalculate()
                
                updatedDatedNodes.append(updateDescendantNodes(targetNode))
            }
        }

        return Array(Set<DemoNode>(updatedDatedNodes.flatMap{ $0 })) //  updatedDatedNodes.flatMap{ $0 }
    }
    
    static func nodesAreRelationshipCandidates(sourceNode: DemoNode, targetNode: DemoNode, targetIndex: Int) -> Bool
    {
        // TODO - prevent circular! recursive function 
        
        if sourceNode.isAscendant(targetNode) || sourceNode == targetNode
        {
            return false
        }
        
        return sourceNode.value?.typeName == targetNode.type.inputSlots[targetIndex].type.typeName
    }
}
