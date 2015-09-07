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
        let one = DemoNode(name: "One", position: CGPoint(x: 10, y: 10), value: DemoNodeValue.Number(1))
        let two = DemoNode(name: "Two", position: CGPoint(x: 20, y: 150), value: DemoNodeValue.Number(2))
        let three = DemoNode(name: "Three", position: CGPoint(x: 35, y: 320), value: DemoNodeValue.Number(3))
        let add = DemoNode(name: "Add", position: CGPoint(x: 270, y: 70), type: DemoNodeType.Add, inputs: [one, nil, two, three])
        let subtract = DemoNode(name: "Subtract", position: CGPoint(x: 420, y: 320), type: DemoNodeType.Subtract, inputs: [add, three])
        let multiply = DemoNode(name: "Multiply", position: CGPoint(x: 600, y: 200), type: DemoNodeType.Multiply, inputs: [subtract, add])
        
        nodes = [one, two, three, add, subtract, multiply]
        
        updateDescendantNodes(one)
        updateDescendantNodes(two)
        updateDescendantNodes(three)
    }
    
    mutating func creatRelationship(sourceNode: SNNode, targetNode: SNNode, targetIndex: Int)
    {
        if targetNode.inputs == nil
        {
            targetNode.inputs = [DemoNode]()
        }
        
        targetNode.inputs![0] = sourceNode
        
        updateDescendantNodes(sourceNode.demoNode!)
    }
    
    mutating func addNodeAt(position: CGPoint) -> DemoNode
    {
        let newNode = DemoNode(name: "New!", position: position, value: DemoNodeValue.Number(1))
        
        nodes.append(newNode)
        
        return newNode
    }
    
    func updateDescendantNodes(sourceNode: DemoNode) -> [DemoNode]
    {
        var updatedDatedNodes = [[sourceNode]]
        
        for targetNode in nodes where targetNode != sourceNode
        {
            if let inputs = targetNode.inputs,
                targetNode = targetNode.demoNode where inputs.indexOf({$0 == sourceNode}) != nil
            {
                targetNode.recalculate()
                
                updatedDatedNodes.append(updateDescendantNodes(targetNode))
            }
        }

        return Array(Set<DemoNode>(updatedDatedNodes.flatMap{ $0 })) //  updatedDatedNodes.flatMap{ $0 }
    }
}
