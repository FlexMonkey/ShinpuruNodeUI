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
    let view: SNView
    let node: SNNode
    var inputRowRenderers = [SNInputRowRenderer]()
    var previousPanPoint: CGPoint?
    
    required init(view: SNView, node: SNNode)
    {
        self.view = view
        self.node = node
        
        super.init(frame: CGRect(origin: node.position, size: CGSizeZero))
        
        let pan = UIPanGestureRecognizer(target: self, action: "panHandler:")
        addGestureRecognizer(pan)
        
        setNeedsLayout()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var itemRenderer: SNItemRenderer?
    {
        return view.nodeDelegate?.itemRenderer(view: view, node: node)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        guard let itemRenderer = itemRenderer else
        {
            return
        }
        
        addSubview(itemRenderer)
        
        itemRenderer.frame = CGRect(x: 0,
            y: 0,
            width: itemRenderer.intrinsicContentSize().width,
            height: itemRenderer.intrinsicContentSize().height)
        
        inputRowRenderers.removeAll()
        var inputRowsHeight: CGFloat = 0
        
        for i in 0 ..< node.inputSlots
        {
            if let inputRowRenderer = view.nodeDelegate?.inputRowRenderer(view: view, node: node, index: i)
            {
                addSubview(inputRowRenderer)
                inputRowRenderers.append(inputRowRenderer)
                
                inputRowRenderer.frame = CGRect(x: 0,
                    y: itemRenderer.intrinsicContentSize().height + inputRowsHeight,
                    width: inputRowRenderer.intrinsicContentSize().width,
                    height: inputRowRenderer.intrinsicContentSize().height)
                
                inputRowsHeight += inputRowRenderer.intrinsicContentSize().height
            }
        }
        
        frame = CGRect(x: frame.origin.x,
            y: frame.origin.y,
            width: itemRenderer.intrinsicContentSize().width,
            height: itemRenderer.intrinsicContentSize().height + inputRowsHeight)
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
            
            view.nodeMoved(view, node: node)
        }
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: frame.width, height: frame.height)
    }
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.darkGrayColor()
    }
}
