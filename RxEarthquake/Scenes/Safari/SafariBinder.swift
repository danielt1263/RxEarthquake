//
//  SafariBinder.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/17/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import RxCocoa
import RxSwift
import SafariServices
import UIKit

extension UIViewController {
	func presentSafari(url: URL, animated: Bool) {
		let controller = SFSafariViewController(url: url)
		present(controller, animated: animated)
	}
}
