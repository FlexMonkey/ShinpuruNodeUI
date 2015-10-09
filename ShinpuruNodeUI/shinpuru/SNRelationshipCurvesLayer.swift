//
//  SNRelationshipCurvesLayer.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 02/09/2015.
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

class SNRelationshipCurvesLayer: CALayer
{
    var relationshipLayersDictionary = [SNNodePair: CAShapeLayer]()
    
    func deleteSpecificRelationship(sourceNode sourceNode: SNNode, targetNode: SNNode, targetNodeInputIndex: Int)
    {
        let nodePair = SNNodePair(sourceNode: targetNode, targetNode: sourceNode, targetIndex: targetNodeInputIndex)
   
        if let relationshipLayer = relationshipLayersDictionary[nodePair]
        {
            relationshipLayer.removeFromSuperlayer()
            
            relationshipLayersDictionary.removeValueForKey(nodePair)
        }
    }
    
    func deleteNodeRelationships(deletedNode: SNNode)
    {
        for (key, value) in relationshipLayersDictionary where key.sourceNode == deletedNode || key.targetNode == deletedNode
        {
            value.removeFromSuperlayer()
            
            relationshipLayersDictionary.removeValueForKey(key)
        }
    }
    
    func renderRelationships(nodes: [SNNode], widgetsDictionary: [SNNode: SNNodeWidget], focussedNode: SNNode? = nil)
    {
        drawsAsynchronously = true
        
        CATransaction.begin()
        CATransaction.disableActions()
        CATransaction.setAnimationDuration(0)
    
        let sourceNodeTargets: [SNNode]
        
        if focussedNode != nil
        {
            sourceNodeTargets = nodes.filter
            {
                $0.inputs != nil && $0.inputs!.contains({ $0 == focussedNode })
            }
        }
        else
        {
            sourceNodeTargets = [SNNode]()
        }
        
        for sourceNode in nodes where focussedNode == nil || sourceNode == focussedNode || sourceNodeTargets.contains(sourceNode)
        {
            guard let sourceWidget = widgetsDictionary[sourceNode] else
            {
                continue
            }
            
            if let inputs = sourceNode.inputs
            {
                var inputRowsHeight: CGFloat = 0
                
                // draw relationships...
                for (idx, targetNode) in inputs.enumerate()
                {
                    guard let targetNode = targetNode,
                        targetWidget = widgetsDictionary[targetNode],
                        targetOutputRow = targetWidget.outputRenderer,
                        sourceItemRendererHeight = sourceWidget.itemRenderer?.intrinsicContentSize().height
                        else
                    {
                        if idx < sourceWidget.inputRowRenderers.count
                        {
                            inputRowsHeight += sourceWidget.inputRowRenderers[idx].intrinsicContentSize().height
                        }
                        continue
                    }
                    
                    if idx < sourceWidget.inputRowRenderers.count
                    {
                        let targetWidgetHeight = targetWidget.intrinsicContentSize().height - targetOutputRow.intrinsicContentSize().height
                        let targetWidgetWidth = targetWidget.intrinsicContentSize().width
                        let rowHeight = sourceWidget.inputRowRenderers[idx].intrinsicContentSize().height
                            
                        let inputPosition = CGPoint(x: targetNode.position.x + targetWidgetWidth,
                            y: targetNode.position.y + CGFloat(targetWidgetHeight) + (targetOutputRow.intrinsicContentSize().height / 2))
                        
                        let targetY = sourceNode.position.y + inputRowsHeight + CGFloat(rowHeight / 2) + sourceItemRendererHeight + SNNodeWidget.titleBarHeight
                        
                        let targetPosition = CGPoint(x: sourceNode.position.x, y: targetY)
                        
                        let controlPointHorizontalOffset = max(abs(targetPosition.x - inputPosition.x), 40) * 0.75
                        
                        let controlPointOne = CGPoint(x: targetPosition.x - controlPointHorizontalOffset, y: targetY)
                        
                        let controlPointTwo = CGPoint(x: inputPosition.x + controlPointHorizontalOffset, y: inputPosition.y)
                        
                        let relationshipCurvesPath = UIBezierPath()
                        
                        drawTerminal(relationshipCurvesPath, position: inputPosition.offset(4, dy: 0))
                        drawTerminal(relationshipCurvesPath, position: targetPosition.offset(-4, dy: 0))
                        
                        relationshipCurvesPath.moveToPoint(targetPosition.offset(-4, dy: 0))
                        relationshipCurvesPath.addCurveToPoint(inputPosition.offset(4, dy: 0), controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
                        
                        inputRowsHeight += rowHeight
                        
                        let nodePair = SNNodePair(sourceNode: sourceNode, targetNode: targetNode, targetIndex: idx)
                        
                        let layer = layerForNodePair(nodePair)
                        
                        layer.path = relationshipCurvesPath.CGPath
                    }
                }
            }
        }
        
        CATransaction.commit()
    }
    
    func layerForNodePair(nodePair: SNNodePair) -> CAShapeLayer
    {
        if relationshipLayersDictionary[nodePair] == nil
        {
            let layer = CAShapeLayer()
            
            layer.strokeColor = UIColor.whiteColor().CGColor
            layer.lineWidth = 4
            layer.fillColor = nil
            layer.lineCap = kCALineCapSquare
            
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSizeZero
            layer.shadowRadius = 2
            layer.shadowOpacity = 1
            
            relationshipLayersDictionary[nodePair] = layer
            
            addSublayer(layer)
        }
        
        return relationshipLayersDictionary[nodePair]!
    }
    
    func drawTerminal(relationshipCurvesPath: UIBezierPath, position: CGPoint)
    {
        let rect = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: position.x - 2, y: position.y - 2), size: CGSize(width: 4, height: 4)), cornerRadius: 0)
        
        relationshipCurvesPath.appendPath(rect)
    }
    
}

extension CGPoint
{
    func offset(dx: CGFloat, dy: CGFloat) -> CGPoint
    {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
