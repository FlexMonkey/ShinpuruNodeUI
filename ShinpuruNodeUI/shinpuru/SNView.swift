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
    
    weak var nodeDelegate: SNDelegate?
}
