//
//  ViewController.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    let shinpuruNodeUI: SNView = SNView()
    
    let slider = UISlider(frame: CGRectZero)
    let operatorsControl = UISegmentedControl(items: DemoNodeType.operators.map{ $0.rawValue })
    let controlsStackView = UIStackView(frame: CGRectZero)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        buildUserInterface()
        
        let one = DemoNode(name: "One", position: CGPoint(x: 10, y: 10), value: DemoNodeValue.Number(1))
        
        let two = DemoNode(name: "Two", position: CGPoint(x: 20, y: 150), value: DemoNodeValue.Number(2))
        
        let three = DemoNode(name: "Three", position: CGPoint(x: 35, y: 320), value: DemoNodeValue.Number(3))
  
        let add = DemoNode(name: "Add", position: CGPoint(x: 270, y: 70), type: DemoNodeType.Add, inputs: [one, two, three])
        
        let subtract = DemoNode(name: "Subtract", position: CGPoint(x: 420, y: 320), type: DemoNodeType.Subtract, inputs: [one, add, three])
        
        let xxx = DemoNode(name: "xxx", position: CGPoint(x: 600, y: 200), type: DemoNodeType.Subtract, inputs: [subtract, add])
        
        add.inputSlots = 3
        subtract.inputSlots = 3
        xxx.inputSlots = 2
        
        shinpuruNodeUI.nodeDelegate = self 
        
        shinpuruNodeUI.nodes = [one, two, three, add, subtract, xxx]
    }

    func buildUserInterface()
    {
        view.addSubview(shinpuruNodeUI)
        view.backgroundColor = UIColor.darkGrayColor()
        
        // slider
        slider.minimumValue = -10
        slider.maximumValue = 10
        
        slider.enabled = false
        
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        // operators segmented control
        operatorsControl.enabled = false
        
        controlsStackView.distribution = UIStackViewDistribution.FillEqually
        
        controlsStackView.addArrangedSubview(slider)
        controlsStackView.addArrangedSubview(UIView(frame: CGRectZero))
        controlsStackView.addArrangedSubview(operatorsControl)

        view.addSubview(controlsStackView)
    }
    
    // MARK: UI control change handlers
    
    func sliderChangeHandler()
    {
        if let selectedNode = shinpuruNodeUI.selectedNode as? DemoNode where selectedNode.type == .Numeric
        {
            selectedNode.value = DemoNodeValue.Number(slider.value)
            shinpuruNodeUI.reloadNode(selectedNode)
            
            updateDecendentNodes(selectedNode)
        }
    }
    
    // MARK: Nodes stuff
    
    func updateDecendentNodes(sourceNode: DemoNode)
    {
        for targetNode in shinpuruNodeUI.nodes! where targetNode != sourceNode
        {
            if let inputs = targetNode.inputs,
                targetNode = targetNode as? DemoNode where inputs.indexOf({$0 == sourceNode}) != nil
            {
                targetNode.recalculate()
                shinpuruNodeUI.reloadNode(targetNode)
                
                updateDecendentNodes(targetNode)
            }
        }
    }
    
    // MARK: System layout
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let controlsStackViewHeight = max(slider.intrinsicContentSize().height, operatorsControl.intrinsicContentSize().height)
        
        shinpuruNodeUI.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: view.frame.width,
            height: view.frame.height - topLayoutGuide.length - controlsStackViewHeight - 20)

        controlsStackView.frame = CGRect(x: 10,
            y: view.frame.height - controlsStackViewHeight - 10,
            width: view.frame.width - 20,
            height: controlsStackViewHeight)
    }
}

extension ViewController: SNDelegate
{
    func itemRendererForView(view: SNView, node: SNNode) -> SNItemRenderer
    {
        return DemoRenderer(node: node)
    }
    
    func inputRowRendererForView(view: SNView, node: SNNode, index: Int) -> SNInputRowRenderer
    {
        return DemoInputRowRenderer(index: index, node: node)
    }
    
    func outputRowRendererForView(view: SNView, node: SNNode) -> SNOutputRowRenderer
    {
        return DemoOutputRowRenderer(node: node)
    }
    
    func nodeSelectedInView(view: SNView, node: SNNode?)
    {
        guard let node = node as? DemoNode else
        {
            return
        }
        
        switch node.type
        {
        case .Numeric:
            slider.enabled = true
            operatorsControl.enabled = false
            
            if let nodeValue = node.value
            {
                switch nodeValue
                {
                case DemoNodeValue.Number(let value):
                    slider.value = value
                    
                default:
                    slider.value = 0
                    slider.enabled = false
                }
            }
            
        case .Add, .Subtract, .Multiply, .Divide:
            slider.enabled = false
            operatorsControl.enabled = true
            
            if let targetIndex = DemoNodeType.operators.indexOf(DemoNodeType(rawValue: node.type.rawValue)!)
            {
                operatorsControl.selectedSegmentIndex = targetIndex
            }
        }
    }
    
    func nodeMovedInView(view: SNView, node: SNNode)
    {
        // handle a node move - save to CoreData?
    }
}
