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
    static let titleBarHeight: CGFloat = 44
    
    unowned let view: SNView
    unowned let node: SNNode
    var inputRowRenderers = [SNInputRowRenderer]()
    var previousPanPoint: CGPoint?
    
    let titleBar = SNWidgetTitleBar()
    
    required init(view: SNView, node: SNNode)
    {
        self.view = view
        self.node = node
        
        super.init(frame: CGRect(origin: node.position, size: CGSizeZero))
        
        let pan = UIPanGestureRecognizer(target: self, action: "panHandler:")
        addGestureRecognizer(pan)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        addGestureRecognizer(longPress)
        
        setNeedsLayout()
        
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var _itemRenderer: SNItemRenderer?
    
    var itemRenderer: SNItemRenderer?
    {
        if _itemRenderer == nil
        {
            _itemRenderer = view.nodeDelegate?.itemRendererForView(view, node: node)
        }
        
        return _itemRenderer
    }
    
    private var _outputRenderer: SNOutputRowRenderer?
    
    var outputRenderer: SNOutputRowRenderer?
    {
        if _outputRenderer == nil
        {
            _outputRenderer = view.nodeDelegate?.outputRowRendererForView(view, node: node)
        }
        
        return _outputRenderer
    }
    
    func buildUserInterface()
    {
        guard let itemRenderer = itemRenderer,
            outputRenderer = outputRenderer else
        {
            return
        }
        
        // clear down...
        
        itemRenderer.removeFromSuperview()
        outputRenderer.removeFromSuperview()
        
        for inputRendeer in inputRowRenderers
        {
            inputRendeer.removeFromSuperview()
        }
        
        // set up....
        
        // title bar
        
        addSubview(titleBar)
        
        titleBar.title = node.name
        
        titleBar.parentNodeWidget = self
        
        titleBar.frame = CGRect(x: 1,
            y: 0,
            width: itemRenderer.intrinsicContentSize().width,
            height: SNNodeWidget.titleBarHeight)
        
        // main item renderer
        
        addSubview(itemRenderer)
        
        itemRenderer.frame = CGRect(x: 1,
            y: SNNodeWidget.titleBarHeight,
            width: itemRenderer.intrinsicContentSize().width,
            height: itemRenderer.intrinsicContentSize().height)
        
        inputRowRenderers.removeAll()
        var inputOutputRowsHeight: CGFloat = SNNodeWidget.titleBarHeight
        
        for i in 0 ..< node.inputSlots
        {
            if let inputRowRenderer = view.nodeDelegate?.inputRowRendererForView(view, node: node, index: i)
            {
                addSubview(inputRowRenderer)
                inputRowRenderers.append(inputRowRenderer)
                
                inputRowRenderer.frame = CGRect(x: 1,
                    y: itemRenderer.intrinsicContentSize().height + inputOutputRowsHeight,
                    width: inputRowRenderer.intrinsicContentSize().width,
                    height: inputRowRenderer.intrinsicContentSize().height)
                
                inputOutputRowsHeight += inputRowRenderer.intrinsicContentSize().height
        
                if i < node.inputs?.count
                {
                    if let input = node.inputs?[i]
                    {
                        inputRowRenderer.node = input
                        
                        inputRowRenderer.reload()
                    }
                }
            }
        }
        
        addSubview(outputRenderer)
        
        outputRenderer.frame = CGRect(x: 1,
            y: itemRenderer.intrinsicContentSize().height + inputOutputRowsHeight,
            width: outputRenderer.intrinsicContentSize().width,
            height: outputRenderer.intrinsicContentSize().height)
        
        inputOutputRowsHeight += outputRenderer.intrinsicContentSize().height
        
        frame = CGRect(x: frame.origin.x,
            y: frame.origin.y,
            width: itemRenderer.intrinsicContentSize().width + 2,
            height: itemRenderer.intrinsicContentSize().height + inputOutputRowsHeight)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        buildUserInterface()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.superview?.bringSubviewToFront(self)
        
        if let touchLocation = touches.first?.locationInView(self),
            inputNodeWidget = self.hitTest(touchLocation, withEvent: event) as? SNInputRowRenderer,
            targetNodeInputIndex = inputRowRenderers.indexOf(inputNodeWidget)
        {
            view.toggleRelationship(targetNode: node, targetNodeInputIndex: targetNodeInputIndex)
        }
        
        view.selectedNode = node
    }
    
    func deleteHandler()
    {
        view.nodeDeleted(node)
    }
    
    func longPressHandler(recognizer: UILongPressGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            view.relationshipCreationMode = true
        }
    }
    
    func panHandler(recognizer: UIPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            previousPanPoint = recognizer.locationInView(self.superview)
            
            self.superview?.bringSubviewToFront(self)
            
            view.selectedNode = node
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
            
            view.nodeMoved(node)
        }
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: frame.width, height: frame.height)
    }
}

class SNWidgetTitleBar: UIToolbar
{
    let label: UIBarButtonItem
    
    weak var parentNodeWidget: SNNodeWidget?
    
    var title: String = ""
    {
        didSet
        {
            label.title = title
        }
    }
    
    override init(frame: CGRect)
    {
        label = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        super.init(frame: frame)

        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let trash = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteHandler")
        
        items = [label, spacer, trash]
        
        tintColor = UIColor.whiteColor()
        barTintColor = UIColor.darkGrayColor()
    }

    func deleteHandler()
    {
        parentNodeWidget?.deleteHandler()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
