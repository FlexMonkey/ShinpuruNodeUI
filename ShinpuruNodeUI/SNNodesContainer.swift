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
        
        let hGap = Int(frame.width / 50)
        let vGap = Int(frame.height / 50)
        
        print(hGap, vGap)
        
        let gridPath = UIBezierPath()
        
        for i in 0...50
        {
            gridPath.moveToPoint(CGPoint(x: i * hGap, y: 0))
            gridPath.addLineToPoint((CGPoint(x: i * hGap, y: Int(frame.height))))
            
            gridPath.moveToPoint(CGPoint(x: 0, y: i * vGap))
            gridPath.addLineToPoint((CGPoint(x: Int(frame.width), y: i * vGap)))
        }
        
        gridLayer.strokeColor = UIColor.darkGrayColor().CGColor
        gridLayer.lineWidth = 1
        
        gridLayer.path = gridPath.CGPath
        
        layer.addSublayer(gridLayer)
    }
}
