//
//  SplitViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/14/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift

final class SplitViewController: UIViewController {

	static func create() -> SplitViewController {
		let storyboard = UIStoryboard(name: "Split", bundle: nil)
		return storyboard.instantiateInitialViewController() as! SplitViewController
	}

	// view properties go here.
	
	let disposeBag = DisposeBag()
}
