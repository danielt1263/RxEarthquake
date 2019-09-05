//
//  LocationManager.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/8/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import CoreLocation

final class LocationManager {

	let userLocation: Observable<CLLocation>

	init() {
		locationManager.rx.didChangeAuthorizationStatus
			.subscribe(onNext: { [unowned locationManager] status in
				if status == .authorizedWhenInUse {
					locationManager.startMonitoringSignificantLocationChanges()
				}
			})
			.disposed(by: bag)

		userLocation = locationManager.rx.didUpdateLocations
			.compactMap { $0.last }
			.share()
	}

	private let locationManager: CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.pausesLocationUpdatesAutomatically = true
		locationManager.activityType = .other
		locationManager.requestWhenInUseAuthorization()
		return locationManager
	}()

	private let bag = DisposeBag()
}
