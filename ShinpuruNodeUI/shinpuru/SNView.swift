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
    
    var relationshipCreationMode: Bool = false
    {
        didSet
        {
            nodesView.backgroundColor = relationshipCreationMode ? UIColor(white: 0.75, alpha: 0.75) : nil
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
            relationshipCreationMode = false
            
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        nodesView.addGestureRecognizer(longPress)
    }
    
    func longPressHandler(recognizer: UILongPressGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            nodeDelegate?.nodeCreatedInView(self, position: recognizer.locationInView(nodesView))
        }
    }
    
    func reloadNode(node: SNNode)
    {
        let widget = createWidgetForNode(node)
        
        guard let nodes = nodes,
            itemRenderer = widget.itemRenderer else
        {
            return
        }
        
        if widget.inputRowRenderers.count != node.inputSlots
        {
            widget.buildUserInterface()
            
            setNeedsLayout()
        }
        
        itemRenderer.reload();
        
        for otherNode in nodes where otherNode != node && otherNode.inputs != nil
        {
            for otherNodeInputRenderer in (widgetsDictionary[otherNode]?.inputRowRenderers)! where otherNodeInputRenderer.node == node
            {
                otherNodeInputRenderer.reload()
            }
        }
    }
    
    func nodeDeleted(node: SNNode)
    {
        if let widget = widgetsDictionary[node],
            nodes = nodes
        {
            widget.removeFromSuperview()
            
            for otherNode in nodes where otherNode != node && otherNode.inputs != nil
            {
                for otherNodeInputRenderer in (widgetsDictionary[otherNode]?.inputRowRenderers)! where otherNodeInputRenderer.node == node
                {
                    otherNodeInputRenderer.node = nil
                    otherNodeInputRenderer.reload()
                }
            }
            
            selectedNode = nil
        }
        
        nodeDelegate?.nodeDeletedInView(self, node: node)
    }
    
    func nodeMoved(node: SNNode)
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
            createWidgetForNode(node)
        }
        
        renderRelationships()
    }
    
    func createWidgetForNode(node: SNNode) -> SNNodeWidget
    {
        if let widget = widgetsDictionary[node]
        {
            return widget
        }
        else
        {
            let widget = SNNodeWidget(view: self, node: node)
            
            widgetsDictionary[node] = widget
            
            nodesView.addSubview(widget)
            
            return widget
        }
    }
    
    func toggleRelationship(targetNode targetNode: SNNode, targetNodeInputIndex: Int)
    {
        guard let sourceNode = selectedNode where relationshipCreationMode else
        {
            return
        }
        
        nodeDelegate?.relationshipToggledInView(self,
            sourceNode: sourceNode,
            targetNode: targetNode,
            targetNodeInputIndex: targetNodeInputIndex)
        
        relationshipCreationMode = false
        
        widgetsDictionary[targetNode]?.inputRowRenderers[targetNodeInputIndex].node = targetNode.inputs?[targetNodeInputIndex]
        widgetsDictionary[targetNode]?.inputRowRenderers[targetNodeInputIndex].reload()
        
        reloadNode(targetNode)
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
