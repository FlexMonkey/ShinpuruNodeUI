//
//  SNRelationshipCurvesLayer.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 02/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SNRelationshipCurvesLayer: CAShapeLayer
{
    var relationshipCurvesPath = UIBezierPath()
        
    func renderRelationships(nodes: [SNNode], widgetsDictionary: [SNNode: SNNodeWidget])
    {
        strokeColor = UIColor.whiteColor().CGColor
        lineWidth = 2
        fillColor = nil
        lineCap = kCALineCapSquare
        
        drawsAsynchronously = true
        
        relationshipCurvesPath.removeAllPoints()
        
        for sourceNode in nodes
        {
            guard let sourceWidget = widgetsDictionary[sourceNode] else
            {
                continue
            }
            
            let rect = CGRect(x: CGFloat(sourceNode.position.x),
                y: CGFloat(sourceNode.position.y),
                width: sourceWidget.intrinsicContentSize().width,
                height: sourceWidget.intrinsicContentSize().height).insetBy(dx: -(lineWidth / 2), dy: -(lineWidth / 2))
            
            let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: 0)
            relationshipCurvesPath.appendPath(rectPath)
            print("----")
            if let inputs = sourceNode.inputs
            {
                var inputRowsHeight: CGFloat = 0
                
                // draw relationships...
                for (idx, targetNode) in inputs.enumerate()
                {
                    guard let targetWidget = widgetsDictionary[targetNode] else
                    {
                        continue
                    }
                    
                    if idx < sourceWidget.inputRowRenderers.count
                    {
                        let targetWidgetHeight = targetWidget.intrinsicContentSize().height
                        let targetWidgetWidth = targetWidget.intrinsicContentSize().width
                        let rowHeight = sourceWidget.inputRowRenderers[idx].intrinsicContentSize().height
                            
                        let inputPosition = CGPoint(x: targetNode.position.x + targetWidgetWidth,
                            y: CGFloat(targetWidgetHeight / 2) - CGFloat(targetWidgetHeight) +  targetNode.position.y + CGFloat(targetWidgetHeight))
                        
                        let targetY = sourceNode.position.y + targetWidgetHeight + inputRowsHeight + CGFloat(rowHeight / 2)
                        
                        let targetPosition = CGPoint(x: sourceNode.position.x, y: targetY)
                        
                        let controlPointHorizontalOffset = max(abs(targetPosition.x - inputPosition.x), 40) * 0.75
                        
                        let controlPointOne = CGPoint(x: targetPosition.x - controlPointHorizontalOffset, y: targetY)
                        
                        let controlPointTwo = CGPoint(x: inputPosition.x + controlPointHorizontalOffset, y: inputPosition.y)
                        
                        relationshipCurvesPath.moveToPoint(targetPosition)
                        relationshipCurvesPath.addCurveToPoint(inputPosition, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
                        
                        inputRowsHeight += rowHeight
                    }
                }
            }
        }
        
        path = relationshipCurvesPath.CGPath
    }
}
