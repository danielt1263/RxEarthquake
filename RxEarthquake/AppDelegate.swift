//
//  AppDelegate.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import CoreLocation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		window = UIWindow(frame: UIScreen.main.bounds).setup {
			$0.rootViewController = UISplitViewController().configure { $0.connect() }
			$0.makeKeyAndVisible()
		}
		
		_ = locationManager.rx.didChangeAuthorizationStatus
			.filter { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
			.map(to: ())
			.take(until: rx.deallocating)
			.bind {
				locationManager.startMonitoringSignificantLocationChanges()
			}

		return true
	}
}

let locationManager: CLLocationManager = {
	let locationManager = CLLocationManager()
	locationManager.pausesLocationUpdatesAutomatically = true
	locationManager.desiredAccuracy = 3000
	locationManager.activityType = .other
	locationManager.requestWhenInUseAuthorization()
	return locationManager
}()
