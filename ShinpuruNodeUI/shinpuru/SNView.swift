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
    
    weak var nodeDelegate: SNDelegate? // todo: on set of this, rerender nodes
    
    let curvesLayer = SNRelationshipCurvesLayer()
    let nodesView = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blackColor()
        
        nodesView.backgroundColor = UIColor.darkGrayColor()
        
        layer.addSublayer(curvesLayer)
        
        addSubview(nodesView)
    }
    
    func renderRelationships()
    {
        curvesLayer.nodes = nodes
    }
    
    func renderNodes()
    {
        guard let nodes = nodes else
        {
            return
        }
        
        for node in nodes
        {
            let widget = SNNodeWidget(shinpuruNodeView: self, node: node)
            
            widget.itemRenderer = nodeDelegate?.itemRenderer(self)
            
            nodesView.addSubview(widget)
        }
    }
}
