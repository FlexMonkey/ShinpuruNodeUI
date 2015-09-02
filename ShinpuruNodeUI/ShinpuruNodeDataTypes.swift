//
//  ShinpuruNodeDataTypes.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

/// Node value object

protocol SNNode
{
    var inputs: [SNNode]? {get set}
    
    var position: CGPoint {get set}
    
    var name: String {get set}
}

/// SNView delegate protocol

protocol SNDelegate: NSObjectProtocol
{
    func itemRenderer(view:SNView) -> SNItemRenderer
}

/// Base class for node item renderer

class SNItemRenderer: UIView
{
    var node: SNNode?
}
