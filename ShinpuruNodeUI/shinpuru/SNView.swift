//
//  ShinpuruNodeUI.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SNView: UIScrollView
{
    var nodes: [SNNode]?
    {
        didSet
        {
            renderNodes()
        }
    }
    
    var widgetsDictionary = [SNNode: SNNodeWidget]() // needs to be a tuple of widget and size metrics (e.g. item renderer, input count * row height)
    
    weak var nodeDelegate: SNDelegate? // todo: on set of this, rerender nodes
    
    let curvesLayer = SNRelationshipCurvesLayer()
    let nodesView = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blackColor()
        
        layer.addSublayer(curvesLayer)
        
        addSubview(nodesView)
    }
    
    func nodeMoved(view: SNView, node: SNNode)
    {
        nodeDelegate?.nodeMoved(self, node: node)
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
            if widgetsDictionary[node] == nil
            {
                let widget = SNNodeWidget(shinpuruNodeView: self, node: node)
                
                widgetsDictionary[node] = widget
                
                widget.itemRenderer = nodeDelegate?.itemRenderer(self)
                
                nodesView.addSubview(widget)
            }
        }
        
        renderRelationships()
    }
    
    func renderRelationships()
    {
        if let nodes = nodes
        {
            curvesLayer.renderRelationships(nodes, widgetsDictionary: widgetsDictionary)
        }
    }
}
