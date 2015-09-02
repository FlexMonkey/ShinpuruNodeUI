//
//  ViewController.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SNDelegate
{
    let shinpuruNodeUI: SNView = SNView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.addSubview(shinpuruNodeUI)
        
        let one = DemoNode(name: "One", position: CGPoint(x: 10, y: 10), value: DemoNodeValue.float(value: 1))
        
        let two = DemoNode(name: "Two", position: CGPoint(x: 20, y: 150), value: DemoNodeValue.float(value: 2))
        
        let result = DemoNode(name: "Result", position: CGPoint(x: 170, y: 70), type: DemoNodeType.Addition, inputs: [one, two])
        
        shinpuruNodeUI.nodes = [one, two, result]
        
        shinpuruNodeUI.nodeDelegate = self
    }

    // MARK: SNDelegate
    
    func itemRenderer(view:SNView) -> SNItemRenderer
    {
        return DemoRenderer()
    }
    
}

class DemoRenderer: SNItemRenderer
{
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.redColor()
        
        print( (node as? DemoNode)?.value )
    }
}


