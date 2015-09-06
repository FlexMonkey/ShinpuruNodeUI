//
//  ShinpuruNodeUI.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SNView: UIScrollView
{
    private var widgetsDictionary = [SNNode: SNNodeWidget]()
    private let curvesLayer = SNRelationshipCurvesLayer()
    private let nodesView = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))
    
    var nodes: [SNNode]?
    {
        return nodeDelegate?.dataProviderForView(self)
    }
    
    weak var nodeDelegate: SNDelegate?
    {
        didSet
        {
            renderNodes()
        }
    }
    
    var selectedNode: SNNode?
    {
        didSet
        {
            if let previousNode = oldValue
            {
                widgetsDictionary[previousNode]?.layer.shadowColor = nil
                widgetsDictionary[previousNode]?.layer.shadowRadius = 0
                widgetsDictionary[previousNode]?.layer.shadowOpacity = 0
            }
            
            nodeDelegate?.nodeSelectedInView(self, node: selectedNode)
            
            if let selectedNode = selectedNode
            {
                widgetsDictionary[selectedNode]?.layer.shadowColor = UIColor.yellowColor().CGColor
                widgetsDictionary[selectedNode]?.layer.shadowRadius = 10
                widgetsDictionary[selectedNode]?.layer.shadowOpacity = 1
                widgetsDictionary[selectedNode]?.layer.shadowOffset = CGSize(width: 0, height: 0)
            }
        }
    }
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blackColor()
        
        layer.addSublayer(curvesLayer)
        
        addSubview(nodesView)
        
        renderNodes()
    }
    
    func reloadNode(node: SNNode)
    {
        guard let nodes = nodes,
            widget = widgetsDictionary[node],
            itemRenderer = widgetsDictionary[node]?.itemRenderer else
        {
            return
        }
        
        if widget.inputRowRenderers.count != node.inputSlots
        {
            widget.buildUserInterface()
            
            renderRelationships()
        }
        
        itemRenderer.reload()
        
        for otherNode in nodes where otherNode != node && otherNode.inputs != nil
        {
            for otherNodeInputRenderer in (widgetsDictionary[otherNode]?.inputRowRenderers)!
            {
                if otherNodeInputRenderer.node == node
                {
                    otherNodeInputRenderer.reload()
                }
            }
        }
    }
    
    func nodeMoved(view: SNView, node: SNNode)
    {
        nodeDelegate?.nodeMovedInView(self, node: node)
        renderRelationships()
    }
    
    func renderNodes()
    {
        guard let nodes = nodes else
        {
            return
        }
        
        for node in nodes
        {
            if widgetsDictionary[node] == nil
            {
                let widget = SNNodeWidget(view: self, node: node)
                
                widgetsDictionary[node] = widget
                
                nodesView.addSubview(widget)
            }
        }
        
        renderRelationships()
    }
    
    func renderRelationships()
    {
        if let nodes = nodes
        {
            curvesLayer.renderRelationships(nodes, widgetsDictionary: widgetsDictionary)
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        renderNodes()
    }
}
