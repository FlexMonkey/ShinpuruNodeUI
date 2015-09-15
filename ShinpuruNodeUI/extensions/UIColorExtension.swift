//
//  UIColorExtension.swift
//  ShinpuruNodeUI
//
//  Created by Simon Gladman on 15/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

extension UIColor
{
    class func colorFromFloats(redComponent redComponent: Float, greenComponent: Float, blueComponent: Float) -> UIColor
    {
        return UIColor(red: CGFloat(redComponent), green: CGFloat(greenComponent), blue: CGFloat(blueComponent), alpha: 1.0)
    }
    
    class func colorFromDoubles(redComponent redComponent: Double, greenComponent: Double, blueComponent: Double) -> UIColor
    {
        return UIColor(red: CGFloat(redComponent), green: CGFloat(greenComponent), blue: CGFloat(blueComponent), alpha: 1.0)
    }
    
    class func colorFromNSNumbers(redComponent redComponent: NSNumber, greenComponent: NSNumber, blueComponent: NSNumber) -> UIColor
    {
        return UIColor(red: CGFloat(redComponent), green: CGFloat(greenComponent), blue: CGFloat(blueComponent), alpha: 1.0)
    }
    
    func multiply(value: Float) -> UIColor
    {
        let newRed = CGFloat(getRGB().redComponent * value)
        let newGreen = CGFloat(getRGB().greenComponent * value)
        let newBlue = CGFloat(getRGB().blueComponent * value)
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    func getRGB() -> (redComponent: Float, greenComponent: Float, blueComponent: Float)
    {
        if CGColorGetNumberOfComponents(self.CGColor) == 4
        {
            let colorRef = CGColorGetComponents(self.CGColor);
            
            let redComponent = zeroIfDodgy(Float(colorRef[0]))
            let greenComponent = zeroIfDodgy(Float(colorRef[1]))
            let blueComponent = zeroIfDodgy(Float(colorRef[2]))
            
            return (redComponent: redComponent, greenComponent: greenComponent, blueComponent: blueComponent)
        }
        else
        {
            return (redComponent: 0, greenComponent: 0, blueComponent: 0)
        }
    }
    
    func zeroIfDodgy(value: Float) ->Float
    {
        if isnan(value) || isinf(value)
        {
            return 0
        }
        else
        {
            return value
        }
    }
    
    func getHex() -> String
    {
        var returnString = ""
        
        let rgb = self.getRGB()
        
        let red = NSString(format: "%02X", Int(rgb.redComponent * 255))
        let green = NSString(format: "%02X", Int(rgb.greenComponent * 255))
        let blue = NSString(format: "%02X", Int(rgb.blueComponent * 255))
        
        return (red as String) + (green as String) + (blue as String)
    }
    
    func makeDarker() -> UIColor
    {
        let red = getRGB().redComponent * 0.9
        let green = getRGB().greenComponent * 0.9
        let blue = getRGB().blueComponent * 0.9
        
        return UIColor.colorFromFloats(redComponent: red, greenComponent: green, blueComponent: blue)
    }
    
    func makeLighter() -> UIColor
    {
        let red = min(getRGB().redComponent * 1.1, 1.0)
        let green = min(getRGB().greenComponent * 1.1, 1.0)
        let blue = min(getRGB().blueComponent * 1.1, 1.0)
        
        return UIColor.colorFromFloats(redComponent: red, greenComponent: green, blueComponent: blue)
    }
    
}
