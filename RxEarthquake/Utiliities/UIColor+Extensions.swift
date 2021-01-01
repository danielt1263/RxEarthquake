//
//  UIColorExtensions.swift
//
//  Created by Daniel Tartaglia on 12/4/14.
//  Copyright (c) 2014 Daniel Tartaglia. MIT License.
//

import UIKit


extension UIColor {

	convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
		let red   = (hex & 0xFF0000) >> 16
		let green = (hex & 0x00FF00) >>  8
		let blue  = (hex & 0x0000FF)
		let max: CGFloat = 255
		self.init(red: CGFloat(red)/max, green: CGFloat(green)/max, blue: CGFloat(blue)/max, alpha: alpha)
	}

}
