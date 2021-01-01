//
//  SplitBinder.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/14/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import CoreLocation
import RxCocoa
import RxSwift
import UIKit

extension UISplitViewController {
	func bind() {
		let masterScene = EarthquakeListViewController.scene { $0.bind() }
		let masterNavigation = UINavigationController(rootViewController: masterScene.controller)

		let detail = EarthquakeDetailViewController.create {
			$0.bind(earthquake: masterScene.action, userLocation: locationManager.rx.didUpdateLocations.compactMap { $0.last })
		}
		let detailNavigation = UINavigationController(rootViewController: detail)

		viewControllers = [masterNavigation, detailNavigation]
		preferredDisplayMode = .allVisible

		_ = locationManager.rx.didChangeAuthorizationStatus
			.filter { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
			.map(to: ())
			.take(until: rx.deallocating)
			.bind {
				locationManager.startMonitoringSignificantLocationChanges()
			}

		_ = masterScene.action
			.map(to: ())
			.take(until: rx.deallocating)
			.bind {
				self.showDetailViewController(detailNavigation, sender: nil)
			}

		_ = masterScene.action
			.map(to: false)
			.startWith(true)
			.take(until: rx.deallocating)
			.bind(to: rx.collapseSecondaryOntoPrimary)
	}
}

private let locationManager: CLLocationManager = {
	let locationManager = CLLocationManager()
	locationManager.pausesLocationUpdatesAutomatically = true
	locationManager.desiredAccuracy = 3000
	locationManager.activityType = .other
	locationManager.requestWhenInUseAuthorization()
	return locationManager
}()
