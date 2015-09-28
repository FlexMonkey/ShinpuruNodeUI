//
//  UIColorExtension.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 15/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

extension UIColor
{
    func multiply(value: CGFloat) -> UIColor
    {
        let newRed = getRGBA().red * value
        let newGreen = getRGBA().green * value
        let newBlue = getRGBA().blue * value
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    func getRGBA() -> RGBA
    {
        func zeroIfDodgy(value: CGFloat) -> CGFloat
        {
            return isnan(value) || isinf(value) ? 0 : value
        }
        
        if CGColorGetNumberOfComponents(self.CGColor) == 4
        {
            let colorRef = CGColorGetComponents(self.CGColor);
            
            let redComponent = zeroIfDodgy(colorRef[0])
            let greenComponent = zeroIfDodgy(colorRef[1])
            let blueComponent = zeroIfDodgy(colorRef[2])
            let alphaComponent = zeroIfDodgy(colorRef[3])
            
            return RGBA(red: redComponent,
                green: greenComponent,
                blue: blueComponent,
                alpha: alphaComponent)
        }
        else if CGColorGetNumberOfComponents(self.CGColor) == 2
        {
            let colorRef = CGColorGetComponents(self.CGColor);
            
            let greyComponent = zeroIfDodgy(colorRef[0])
            let alphaComponent = zeroIfDodgy(colorRef[1])
            
            return RGBA(red: greyComponent,
                green: greyComponent,
                blue: greyComponent,
                alpha: alphaComponent)
        }
        else
        {
            return RGBA(red: 0,
                green: 0,
                blue: 0,
                alpha: 0)
        }
    }
    
    func getHex() -> String
    {
        let rgba = self.getRGBA()
        
        let red = String(format: "%02X", Int(rgba.red * 255))
        let green = String(format: "%02X", Int(rgba.green * 255))
        let blue = String(format: "%02X", Int(rgba.blue * 255))
        
        return (red as String) + (green as String) + (blue as String)
    }
    
}
