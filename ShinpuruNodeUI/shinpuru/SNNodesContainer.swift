//
//  SNNodesContainer.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 12/09/2015.
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
            gridPath.move(to: CGPoint(x: i * hGap, y: 0))
            gridPath.addLine(to: (CGPoint(x: i * hGap, y: height)))
            
            gridPath.move(to: CGPoint(x: 0, y: i * vGap))
            gridPath.addLine(to: (CGPoint(x: width, y: i * vGap)))
        }
        
        gridLayer.strokeColor = UIColor(white: 0.2, alpha: 1).cgColor
        gridLayer.lineWidth = 2
        
        gridLayer.path = gridPath.cgPath
        
        layer.addSublayer(gridLayer)
    }
}
