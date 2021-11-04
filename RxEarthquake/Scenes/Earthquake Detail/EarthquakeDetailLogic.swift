//
//  EarthquakeDetailLogic.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import CoreLocation
import Foundation
import RxSwift

enum EarthquakeDetailLogic {
	
	static func magnitude(earthquake: Earthquake) -> String? {
		magnitudeFormatter.string(from: earthquake.magnitude as NSNumber)
	}
	
	static func depth(earthquake: Earthquake) -> String {
		depthFormatter.string(fromMeters: earthquake.depth)
	}
	
	static func time(earthquake: Earthquake) -> String {
		timestampFormatter.string(from: earthquake.timestamp)
	}
	
	static func distance(earthquake: Earthquake, authorization: Observable<CLAuthorizationStatus>, userLocations: Observable<[CLLocation]>) -> Observable<String> {
		Observable.combineLatest(authorization, userLocations.startWith([]))
		{ (authorization, locations) -> String in
			if let location = locations.last, authorization == .authorizedAlways || authorization == .authorizedWhenInUse {
				return distanceFormatter.string(fromMeters: location.distance(from: earthquake.location))
			}
			else {
				return "Unknown"
			}
		}
	}
	
	static func presentAlert(earthquake: Earthquake, itemSelected: Observable<IndexPath>) -> Observable<(title: String, message: String)> {
		weblink(earthquake: earthquake, itemSelected: itemSelected)
			.filter { $0 == nil }
			.map(to: ())
			.map { (title: "No Information", message: "No other information is available for this earthquake") }
	}
	
	static func presentSafari(earthquake: Earthquake, itemSelected: Observable<IndexPath>) -> Observable<URL> {
		weblink(earthquake: earthquake, itemSelected: itemSelected)
			.compactMap { $0 }
	}
	
	static func presentShare(earthquake: Earthquake, shareTrigger: Observable<Void>) -> Observable<[Any]> {
		shareTrigger
			.map(to: [earthquake.location as Any] + (earthquake.weblink.map { [$0 as Any] } ?? []))
	}
}

private func weblink(earthquake: Earthquake, itemSelected: Observable<IndexPath>) -> Observable<URL?> {
	itemSelected
		.filter { $0.section == 1 && $0.row == 0 }
		.map(to: earthquake.weblink)
}

private
let magnitudeFormatter: NumberFormatter = {
	let result = NumberFormatter()
	result.numberStyle = .decimal
	result.maximumFractionDigits = 1
	result.minimumFractionDigits = 1
	return result
}()

private
let depthFormatter: LengthFormatter = {
	let result = LengthFormatter()
	result.isForPersonHeightUse = false
	return result
}()

private
let timestampFormatter: DateFormatter = {
	let timestampFormatter = DateFormatter()
	
	timestampFormatter.dateStyle = .medium
	timestampFormatter.timeStyle = .medium
	
	return timestampFormatter
}()

private
let distanceFormatter: LengthFormatter = {
	let result = LengthFormatter()
	result.isForPersonHeightUse = false
	result.numberFormatter.maximumFractionDigits = 2
	return result
}()
