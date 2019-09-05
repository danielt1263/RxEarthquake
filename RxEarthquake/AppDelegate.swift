//
//  AppDelegate.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/2/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var coordinator: Coordinator?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		coordinator = Coordinator(splitViewController: window!.rootViewController as! UISplitViewController)

		let _ = isNetworkActive
			.throttle(.milliseconds(500))
			.drive(onNext: { on in
				application.isNetworkActivityIndicatorVisible = on
			})


		return true
	}

}
