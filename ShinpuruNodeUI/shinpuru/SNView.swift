//
//  ShinpuruNodeUI.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
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

class SNView: UIScrollView, UIScrollViewDelegate
{
    private var widgetsDictionary = [SNNode: SNNodeWidget]()
    private let curvesLayer = SNRelationshipCurvesLayer()
    private let nodesContainer = SNNodesContainer(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))

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
            nodesContainer.backgroundColor = relationshipCreationMode ? UIColor(white: 0.75, alpha: 0.75) : nil
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
        minimumZoomScale = 0.5
        maximumZoomScale = 2.0
        delegate = self
        
        backgroundColor = UIColor.blackColor()
  
        nodesContainer.layer.addSublayer(curvesLayer)
        
        addSubview(nodesContainer)
        
        renderNodes()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        nodesContainer.addGestureRecognizer(longPress)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent: event)
        
        relationshipCreationMode = false
    }
    
    func longPressHandler(recognizer: UILongPressGestureRecognizer)
    {
        if let nodeDelegate = nodeDelegate where recognizer.state == UIGestureRecognizerState.Began
        {
            let newPodePosition = CGPoint(
                x: recognizer.locationInView(nodesContainer).x - nodeDelegate.defaultNodeSize(self).width / 2,
                y: recognizer.locationInView(nodesContainer).y - nodeDelegate.defaultNodeSize(self).height / 2)
            
            nodeDelegate.nodeCreatedInView(self, position: newPodePosition)
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
        
        widget.titleBar.label.title = node.name
        
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
            selectedNode = nil
            
            widgetsDictionary.removeValueForKey(node)
            
            widget.removeFromSuperview()
            
            for otherNode in nodes where otherNode != node && otherNode.inputs != nil
            {
                for otherNodeInputRenderer in (widgetsDictionary[otherNode]?.inputRowRenderers)! where otherNodeInputRenderer.node == node
                {
                    otherNodeInputRenderer.node = nil
                    otherNodeInputRenderer.reload()
                }
            }
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
            
            nodesContainer.addSubview(widget)
            
            nodesContainer.bringSubviewToFront(widget)
            
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return nodesContainer
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        renderNodes()
    }
}
