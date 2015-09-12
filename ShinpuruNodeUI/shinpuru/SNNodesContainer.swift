//
//  SNNodesContainer.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 12/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SNNodesContainer: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        drawGrid()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawGrid()
    {
        let gridLayer = CAShapeLayer()
        
        let height = Int(frame.height)
        let width = Int(frame.width)
        
        let hGap = width / 50
        let vGap = height / 50

        let gridPath = UIBezierPath()
        
        for i in 0...50
        {
            gridPath.moveToPoint(CGPoint(x: i * hGap, y: 0))
            gridPath.addLineToPoint((CGPoint(x: i * hGap, y: height)))
            
            gridPath.moveToPoint(CGPoint(x: 0, y: i * vGap))
            gridPath.addLineToPoint((CGPoint(x: width, y: i * vGap)))
        }
        
        gridLayer.strokeColor = UIColor(white: 0.2, alpha: 1).CGColor
        gridLayer.lineWidth = 2
        
        gridLayer.path = gridPath.CGPath
        
        layer.addSublayer(gridLayer)
    }
}