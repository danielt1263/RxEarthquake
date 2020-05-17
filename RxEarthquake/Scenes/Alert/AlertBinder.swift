//
//  AlertBinder.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/17/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
	func presentAlert(title: String, message: String, animated: Bool) {
		let controller = UIAlertController(title: title.isEmpty ? nil : title, message: message.isEmpty ? nil : message, preferredStyle: .alert)
		controller.addAction(UIAlertAction(title: "OK", style: .default))
		present(controller, animated: animated)
	}
}
