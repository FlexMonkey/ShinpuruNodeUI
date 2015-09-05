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
    
    weak var nodeDelegate: SNDelegate?
    {
        didSet
        {
            renderNodes()
        }
    }
    
    private var widgetsDictionary = [SNNode: SNNodeWidget]()
    private let curvesLayer = SNRelationshipCurvesLayer()
    private let nodesView = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blackColor()
        
        layer.addSublayer(curvesLayer)
        
        addSubview(nodesView)
    }
    
    func nodeMoved(view: SNView, node: SNNode)
    {
        nodeDelegate?.nodeMovedInView(self, node: node)
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
                let widget = SNNodeWidget(view: self, node: node)
                
                widgetsDictionary[node] = widget
                
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
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        renderNodes()
    }
}
