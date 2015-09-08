//
//  ViewController.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

/*
    To do
        
    * delete nodes
    * build relationships ** do index!!!
    * remove relatinships

*/

import UIKit

class ViewController: UIViewController
{
    let shinpuruNodeUI = SNView()
    
    var demoModel = DemoModel()
    
    let slider: UISlider
    let operatorsControl: UISegmentedControl
    let controlsStackView: UIStackView
    
    required init?(coder aDecoder: NSCoder)
    {
        slider = UISlider(frame: CGRectZero)
        operatorsControl = UISegmentedControl(items: DemoNodeType.operators.map{ $0.rawValue })
        controlsStackView = UIStackView(frame: CGRectZero)
        
        super.init(coder: aDecoder)

        shinpuruNodeUI.nodeDelegate = self
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        buildUserInterface()
    }

    func buildUserInterface()
    {
        view.addSubview(shinpuruNodeUI)
        view.backgroundColor = UIColor.darkGrayColor()
        
        // slider
        slider.minimumValue = -10
        slider.maximumValue = 10
        slider.tintColor = UIColor.whiteColor()
        slider.enabled = false
        
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        // operators segmented control
        operatorsControl.enabled = false
        operatorsControl.tintColor = UIColor.whiteColor()
        operatorsControl.addTarget(self, action: "operatorsControlChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        // toolbar stak view
        controlsStackView.distribution = UIStackViewDistribution.FillEqually
        
        controlsStackView.addArrangedSubview(slider)
        controlsStackView.addArrangedSubview(UIView(frame: CGRectZero))
        controlsStackView.addArrangedSubview(operatorsControl)

        view.addSubview(controlsStackView)
    }
    
    // MARK: UI control change handlers
    
    func operatorsControlChangeHandler()
    {
        if let selectedNode = shinpuruNodeUI.selectedNode?.demoNode where selectedNode.type.isOperator
        {
            selectedNode.type = DemoNodeType.operators[operatorsControl.selectedSegmentIndex]
            
            demoModel.updateDescendantNodes(selectedNode).forEach{ shinpuruNodeUI.reloadNode($0) }
        }
    }
    
    func sliderChangeHandler()
    {
        if let selectedNode = shinpuruNodeUI.selectedNode?.demoNode where selectedNode.type == .Numeric
        {
            selectedNode.value = DemoNodeValue.Number(round(slider.value))
            
            demoModel.updateDescendantNodes(selectedNode).forEach{ shinpuruNodeUI.reloadNode($0) }
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
    func dataProviderForView(view: SNView) -> [SNNode]?
    {
        return demoModel.nodes
    }
    
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
        guard let node = node?.demoNode else
        {
            return
        }
        
        switch node.type
        {
        case .Numeric:
            slider.enabled = true
            operatorsControl.enabled = false
            operatorsControl.selectedSegmentIndex = -1
            
            if let nodeValue = node.value
            {
                switch nodeValue
                {
                case DemoNodeValue.Number(let value):
                    slider.value = value
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
    
    func nodeCreatedInView(view: SNView, position: CGPoint)
    {
        let newNode = demoModel.addNodeAt(position)
        
        shinpuruNodeUI.reloadNode(newNode)
    }
    
    func relationshipCreatedInView(view: SNView, sourceNode: SNNode, targetNode: SNNode, targetNodeInputIndex: Int)
    {
        demoModel.creatRelationship(sourceNode, targetNode: targetNode, targetIndex: targetNodeInputIndex)
    }
}
