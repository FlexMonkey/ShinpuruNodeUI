//
//  OptionalComparisonOperator.swift
//  ShinpuruNodeUI
//
//  Created by Sash Zats on 9/21/16.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import Foundation

func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

