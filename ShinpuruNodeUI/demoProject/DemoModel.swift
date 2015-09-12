//
//  DemoModel.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 07/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

struct DemoModel
{
    var nodes: [DemoNode]
    
    init()
    {
        let one = DemoNode(name: "One", position: CGPoint(x: 210, y: 10), value: DemoNodeValue.Number(1))
        let two = DemoNode(name: "Two", position: CGPoint(x: 220, y: 350), value: DemoNodeValue.Number(2))
        let add = DemoNode(name: "Add", position: CGPoint(x: 570, y: 170), type: DemoNodeType.Add, inputs: [one, nil, two, nil])
        
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
}
