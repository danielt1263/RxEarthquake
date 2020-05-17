//
//  ActivityBinder.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/17/20.
//  Copyright © 2020 Daniel Tartaglia. MIT License.
//

import RxCocoa
import RxSwift
import UIKit

extension UIViewController {
	func presentActivity(shareInfo: ShareInfo, animated: Bool) {
		let controller = UIActivityViewController(activityItems: shareInfo.items, applicationActivities: nil)
		controller.popoverPresentationController?.barButtonItem = shareInfo.barButtonItem as? UIBarButtonItem
		present(controller, animated: animated)
	}
}
