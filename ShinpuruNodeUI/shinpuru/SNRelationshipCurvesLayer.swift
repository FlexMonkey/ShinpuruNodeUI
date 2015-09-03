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
    
    var nodes: [SNNode]?
    {
        didSet
        {
            renderRelationships()
        }
    }
    
    func renderRelationships()
    {
        guard let nodes = nodes else
        {
            return
        }
        
        strokeColor = UIColor.whiteColor().CGColor
        lineWidth = 2
        fillColor = nil
        
        drawsAsynchronously = true
        
        relationshipCurvesPath.removeAllPoints()
        
        for targetNode in nodes
        {
            let targetWidgetHeight = CGFloat(100)
            let targetWidgetHeightInt = Int(targetWidgetHeight)
            
            let rect = CGRect(x: CGFloat(targetNode.position.x + 1), y: CGFloat(targetNode.position.y + 1), width: 100 - 2, height: targetWidgetHeight - 2)
            let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
            relationshipCurvesPath.appendPath(rectPath)
   
            if let inputs = targetNode.inputs
            {
            // draw relationships...
            for (idx, inputNode) in inputs.enumerate()
            {


                    let inputWidgetHeight = CGFloat(100)
                    let inputWidgetHeightInt = Int(inputWidgetHeight)
                    
                    let inputPosition = CGPoint(x: inputNode.position.x + 100, y: CGFloat(100 / 2) - CGFloat(100) +  inputNode.position.y + CGFloat(100))
                    
                    let targetY = targetNode.position.y + CGFloat(idx * 20 + 20) + CGFloat(20 / 2)
                    
                    let targetPosition = CGPoint(x: targetNode.position.x, y: targetY)
                    
                    let controlPointOne = CGPoint(x: targetNode.position.x - 10, y: targetY)
                    
                    let controlPointTwo = CGPoint(x: inputNode.position.x + 100 + 10, y: inputPosition.y)
               
                    relationshipCurvesPath.moveToPoint(targetPosition)
                    relationshipCurvesPath.addCurveToPoint(inputPosition, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)

                }
            }
        }
        
        path = relationshipCurvesPath.CGPath
    }
}
