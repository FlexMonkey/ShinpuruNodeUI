//
//  ViewController.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 01/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

/*
    To do
        
    * prevent recursive relationships
    * node output type (e.g. color)

*/

import UIKit

class ViewController: UIViewController
{
    let shinpuruNodeUI = SNView()
    
    var demoModel = DemoModel()
    
    let slider: UISlider
    let operatorsControl: UISegmentedControl
    let controlsStackView: UIStackView
    let isOperatorSwitch: UISwitch
    
    required init?(coder aDecoder: NSCoder)
    {
        slider = UISlider(frame: CGRectZero)
        operatorsControl = UISegmentedControl(items: DemoNodeType.operators.map{ $0.rawValue })
        isOperatorSwitch = UISwitch(frame: CGRectZero)
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
        slider.minimumValue = 0
        slider.maximumValue = 255
        slider.tintColor = UIColor.whiteColor()
        slider.enabled = false
        
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        // operators segmented control
        operatorsControl.enabled = false
        operatorsControl.tintColor = UIColor.whiteColor()
        operatorsControl.addTarget(self, action: "operatorsControlChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        // isOperatorSwitch
        isOperatorSwitch.enabled = false
        isOperatorSwitch.addTarget(self, action: "isOperatorSwitchChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        // toolbar stack view
        controlsStackView.distribution = UIStackViewDistribution.Fill
        controlsStackView.spacing = 10
        
        viewDidLayoutSubviews()
        
        controlsStackView.addArrangedSubview(slider)
        controlsStackView.addArrangedSubview(isOperatorSwitch)
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
            
            
            shinpuruNodeUI.renderRelationships(inputsChangedNodes: selectedNode)
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
    
    func isOperatorSwitchChangeHandler()
    {
        if let selectedNode = shinpuruNodeUI.selectedNode?.demoNode 
        {
            selectedNode.type = isOperatorSwitch.on
                ? DemoNodeType.Add
                : DemoNodeType.Numeric
            
            demoModel.updateDescendantNodes(selectedNode).forEach{ shinpuruNodeUI.reloadNode($0) }
            
            nodeSelectedInView(shinpuruNodeUI, node: selectedNode)
            
            shinpuruNodeUI.renderRelationships(inputsChangedNodes: selectedNode)
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
    
    func inputRowRendererForView(view: SNView, inputNode: SNNode?, parentNode: SNNode, index: Int) -> SNInputRowRenderer
    {
        return DemoInputRowRenderer(index: index, inputNode: inputNode, parentNode: parentNode)
    }
    
    func outputRowRendererForView(view: SNView, node: SNNode) -> SNOutputRowRenderer
    {
        return DemoOutputRowRenderer(node: node)
    }
    
    func nodeSelectedInView(view: SNView, node: SNNode?)
    {
        guard let node = node?.demoNode else
        {
            slider.enabled = false
            operatorsControl.enabled = false
            isOperatorSwitch.enabled = false
            
            return
        }
        
        isOperatorSwitch.enabled = true
        
        switch node.type
        {
        case .Numeric:
            slider.enabled = true
            operatorsControl.enabled = false
            operatorsControl.selectedSegmentIndex = -1
            isOperatorSwitch.on = false
            
            slider.value = node.value?.floatValue ?? 0
            
        case .Add, .Subtract, .Multiply, .Divide, .Color, .ColorAdjust:
            slider.enabled = false
            operatorsControl.enabled = true
            isOperatorSwitch.on = true
            
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
        
        view.reloadNode(newNode)
        
        view.selectedNode = newNode
    }
    
    func nodeDeletedInView(view: SNView, node: SNNode)
    {
        if let node = node.demoNode
        {
            demoModel.deleteNode(node).forEach{ view.reloadNode($0) }
            
            view.renderRelationships(deletedNode: node)
        }
    }
    
    func relationshipToggledInView(view: SNView, sourceNode: SNNode, targetNode: SNNode, targetNodeInputIndex: Int)
    {
        if let targetNode = targetNode.demoNode,
            sourceNode = sourceNode.demoNode
        {
            demoModel.toggleRelationship(sourceNode, targetNode: targetNode, targetIndex: targetNodeInputIndex).forEach{ view.reloadNode($0) }
        }
    }
    
    func defaultNodeSize(view: SNView) -> CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: DemoWidgetWidth + SNNodeWidget.titleBarHeight * 2)
    }
    
    func nodesAreRelationshipCandidates(sourceNode: SNNode, targetNode: SNNode, targetIndex: Int) -> Bool
    {
        guard let sourceNode = sourceNode.demoNode,
            targetNode = targetNode.demoNode else
        {
            return false
        }
        
        return DemoModel.nodesAreRelationshipCandidates(sourceNode, targetNode: targetNode, targetIndex: targetIndex)
    }
}
