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

func createSplit() -> UISplitViewController {
	let controller = UISplitViewController()

	let (master, earthquake) = createEarthquakeList()
	let masterNavigation = UINavigationController(rootViewController: master)

	let detail = createEarthquakeDetail(
		earthquake: earthquake,
		userLocation: locationManager.rx.didUpdateLocations.compactMap { $0.last }
	)
	let detailNavigation = UINavigationController(rootViewController: detail)

	controller.viewControllers = [masterNavigation, detailNavigation]
	controller.preferredDisplayMode = .allVisible

	_ = locationManager.rx.didChangeAuthorizationStatus
		.filter { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
		.map { _ in }
		.takeUntil(controller.rx.deallocating)
		.bind { [weak locationManager] in
			locationManager?.startMonitoringSignificantLocationChanges()
		}

	_ = earthquake
		.map { _ in }
		.takeUntil(controller.rx.deallocating)
		.bind { [unowned controller, unowned detailNavigation] in
			controller.showDetailViewController(detailNavigation, sender: nil)
		}

	_ = earthquake
		.map { _ in false }
		.startWith(true)
		.takeUntil(controller.rx.deallocating)
		.bind(to: controller.rx.collapseSecondaryOntoPrimary)

	return controller
}

private let locationManager: CLLocationManager = {
	let locationManager = CLLocationManager()
	locationManager.pausesLocationUpdatesAutomatically = true
	locationManager.desiredAccuracy = 3000
	locationManager.activityType = .other
	locationManager.requestWhenInUseAuthorization()
	return locationManager
}()
