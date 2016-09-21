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
        slider = UISlider(frame: .zero)
        operatorsControl = UISegmentedControl(items: DemoNodeType.operators.map{ $0.rawValue })
        isOperatorSwitch = UISwitch(frame: .zero)
        controlsStackView = UIStackView(frame: .zero)
        
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
        view.backgroundColor = .darkGray
        
        // slider
        slider.minimumValue = 0
        slider.maximumValue = 255
        slider.tintColor = .white
        slider.isEnabled = false
        
        slider.addTarget(self, action: #selector(ViewController.sliderChangeHandler), for: UIControlEvents.valueChanged)
        
        // operators segmented control
        operatorsControl.isEnabled = false
        operatorsControl.tintColor = .white
        operatorsControl.addTarget(self, action: #selector(ViewController.operatorsControlChangeHandler), for: UIControlEvents.valueChanged)
        
        // isOperatorSwitch
        isOperatorSwitch.isEnabled = false
        isOperatorSwitch.addTarget(self, action: #selector(ViewController.isOperatorSwitchChangeHandler), for: UIControlEvents.valueChanged)
        
        // toolbar stack view
        controlsStackView.distribution = .fill
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
        if let selectedNode = shinpuruNodeUI.selectedNode?.demoNode , selectedNode.type.isOperator
        {
            selectedNode.type = DemoNodeType.operators[operatorsControl.selectedSegmentIndex]
            
            demoModel.updateDescendantNodes(selectedNode).forEach{ shinpuruNodeUI.reloadNode($0) }
            
            
            shinpuruNodeUI.renderRelationships(inputsChangedNodes: selectedNode)
        }
    }
    
    func sliderChangeHandler()
    {
        if let selectedNode = shinpuruNodeUI.selectedNode?.demoNode , selectedNode.type == .Numeric
        {
            selectedNode.value = DemoNodeValue.number(round(slider.value))
            
            demoModel.updateDescendantNodes(selectedNode).forEach{ shinpuruNodeUI.reloadNode($0) }
        }
    }
    
    func isOperatorSwitchChangeHandler()
    {
        if let selectedNode = shinpuruNodeUI.selectedNode?.demoNode 
        {
            selectedNode.type = isOperatorSwitch.isOn
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
        
        let controlsStackViewHeight = max(slider.intrinsicContentSize.height, operatorsControl.intrinsicContentSize.height)
        
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
    func dataProviderForView(_ view: SNView) -> [SNNode]?
    {
        return demoModel.nodes
    }
    
    func itemRendererForView(_ view: SNView, node: SNNode) -> SNItemRenderer
    {
        return DemoRenderer(node: node)
    }
    
    func inputRowRendererForView(_ view: SNView, inputNode: SNNode?, parentNode: SNNode, index: Int) -> SNInputRowRenderer
    {
        return DemoInputRowRenderer(index: index, inputNode: inputNode, parentNode: parentNode)
    }
    
    func outputRowRendererForView(_ view: SNView, node: SNNode) -> SNOutputRowRenderer
    {
        return DemoOutputRowRenderer(node: node)
    }
    
    func nodeSelectedInView(_ view: SNView, node: SNNode?)
    {
        guard let node = node?.demoNode else
        {
            slider.isEnabled = false
            operatorsControl.isEnabled = false
            isOperatorSwitch.isEnabled = false
            
            return
        }
        
        isOperatorSwitch.isEnabled = true
        
        switch node.type
        {
        case .Numeric:
            slider.isEnabled = true
            operatorsControl.isEnabled = false
            operatorsControl.selectedSegmentIndex = -1
            isOperatorSwitch.isOn = false
            
            slider.value = node.value?.floatValue ?? 0
            
        case .Add, .Subtract, .Multiply, .Divide, .Color, .ColorAdjust:
            slider.isEnabled = false
            operatorsControl.isEnabled = true
            isOperatorSwitch.isOn = true
            
            if let targetIndex = DemoNodeType.operators.index(of: DemoNodeType(rawValue: node.type.rawValue)!)
            {
                operatorsControl.selectedSegmentIndex = targetIndex
            }
        }
    }
    
    func nodeMovedInView(_ view: SNView, node: SNNode)
    {
        // handle a node move - save to CoreData?
    }
    
    func nodeCreatedInView(_ view: SNView, position: CGPoint)
    {
        let newNode = demoModel.addNodeAt(position)
        
        view.reloadNode(newNode)
        
        view.selectedNode = newNode
    }
    
    func nodeDeletedInView(_ view: SNView, node: SNNode)
    {
        if let node = node.demoNode
        {
            demoModel.deleteNode(node).forEach{ view.reloadNode($0) }
            
            view.renderRelationships(deletedNode: node)
        }
    }
    
    func relationshipToggledInView(_ view: SNView, sourceNode: SNNode, targetNode: SNNode, targetNodeInputIndex: Int)
    {
        if let targetNode = targetNode.demoNode,
            let sourceNode = sourceNode.demoNode
        {
            demoModel.toggleRelationship(sourceNode, targetNode: targetNode, targetIndex: targetNodeInputIndex).forEach{ view.reloadNode($0) }
        }
    }
    
    func defaultNodeSize(_ view: SNView) -> CGSize
    {
        return CGSize(width: DemoWidgetWidth, height: DemoWidgetWidth + SNNodeWidget.titleBarHeight * 2)
    }
    
    func nodesAreRelationshipCandidates(_ sourceNode: SNNode, targetNode: SNNode, targetIndex: Int) -> Bool
    {
        guard let sourceNode = sourceNode.demoNode,
            let targetNode = targetNode.demoNode else
        {
            return false
        }
        
        return DemoModel.nodesAreRelationshipCandidates(sourceNode, targetNode: targetNode, targetIndex: targetIndex)
    }
}
