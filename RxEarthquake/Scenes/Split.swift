//
//  Split.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import RxSwift
import UIKit

extension UISplitViewController {
	func connect() {
		let master = EarthquakeListViewController.scene { $0.connect() }
		preferredDisplayMode = .automatic

		viewControllers = [UINavigationController(rootViewController: master.controller)]

		_ = master.action
			.take(until: rx.deallocating)
			.bind(onNext: showDetailScene(sender: nil, scene: detailScene(earthquake:)))

		_ = master.action
			.map(to: false)
			.startWith(true)
			.take(until: rx.deallocating)
			.bind(to: rx.collapseSecondaryOntoPrimary)
	}
}

private func detailScene(earthquake: Earthquake) -> Scene<Never> {
	UINavigationController(
		rootViewController: EarthquakeDetailViewController.create { $0.connect(earthquake: earthquake) }
	)
	.scene { _ in Observable<Never>.never() }
}
