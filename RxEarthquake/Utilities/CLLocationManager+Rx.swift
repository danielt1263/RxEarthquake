//
//  CLLocationManager+Rx.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import CoreLocation
import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: CLLocationManager {
	var delegate: CLLocationManagerDelegateProxy {
		CLLocationManagerDelegateProxy.proxy(for: base)
	}
	
	@available(iOS, introduced: 4.2, deprecated: 14.0)
	var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
		delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
			.map { CLAuthorizationStatus(rawValue: Int32(truncating: $0[1] as! NSNumber)) ?? .notDetermined }
			.startWith(CLLocationManager.authorizationStatus())
	}

	var didUpdateLocations: Observable<[CLLocation]> {
		delegate._didUpdateLocations.asObservable()
	}
}

extension CLLocationManager: HasDelegate { }

final class CLLocationManagerDelegateProxy
: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>
, DelegateProxyType
, CLLocationManagerDelegate {
	
	init(parentObject: CLLocationManager) {
		super.init(
			parentObject: parentObject,
			delegateProxy: CLLocationManagerDelegateProxy.self
		)
	}

	deinit {
		_didUpdateLocations.onCompleted()
	}

	public static func registerKnownImplementations() {
		self.register { CLLocationManagerDelegateProxy(parentObject: $0) }
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		_didUpdateLocations.onNext(locations)
	}

	fileprivate let _didUpdateLocations = ReplaySubject<[CLLocation]>.create(bufferSize: 1)
}
