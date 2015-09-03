//
//  SNNodeWidget.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 02/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SNNodeWidget: UIView
{
    let shinpuruNodeView: SNView
    let node: SNNode
    var previousPanPoint: CGPoint?
    
    required init(shinpuruNodeView: SNView, node: SNNode)
    {
        self.shinpuruNodeView = shinpuruNodeView
        self.node = node
        
        super.init(frame: CGRect(origin: node.position, size: CGSizeZero))
        
        let pan = UIPanGestureRecognizer(target: self, action: "panHandler:")
        addGestureRecognizer(pan)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var itemRenderer: SNItemRenderer?
    {
        didSet
        {
            if let previousItemRenderer = oldValue
            {
                previousItemRenderer.removeFromSuperview()
            }
            
            if let itemRenderer = itemRenderer
            {
                addSubview(itemRenderer)
                
                itemRenderer.node = node
                
                itemRenderer.frame = CGRect(x: 0,
                    y: 0,
                    width: itemRenderer.intrinsicContentSize().width,
                    height: itemRenderer.intrinsicContentSize().height)
                
                frame = CGRect(x: frame.origin.x,
                    y: frame.origin.y,
                    width: itemRenderer.intrinsicContentSize().width,
                    height: itemRenderer.intrinsicContentSize().height + CGFloat(node.inputCount * SNInputRowHeight))
            }
        }
    }
    
    func panHandler(recognizer: UIPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            self.superview?.bringSubviewToFront(self)
            
            previousPanPoint = recognizer.locationInView(self.superview)
        }
        else if let previousPanPoint = previousPanPoint where recognizer.state == UIGestureRecognizerState.Changed
        {
            let gestureLocation = recognizer.locationInView(self.superview)
            
            let deltaX = (gestureLocation.x - previousPanPoint.x)
            let deltaY = (gestureLocation.y - previousPanPoint.y) // consider.zoomScale
            
            let newPosition = CGPoint(x: frame.origin.x + deltaX, y: frame.origin.y + deltaY)
            
            frame.origin.x = newPosition.x
            frame.origin.y = newPosition.y
            
            self.previousPanPoint = gestureLocation
            
            node.position = newPosition
            
            shinpuruNodeView.nodeMoved(shinpuruNodeView, node: node)
            
            print(node.name, node.uuid)
        }
    }
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.darkGrayColor()
    }
}
