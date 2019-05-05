//
//  EarthquakeDetailViewModel.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/7/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

struct EarthquakeDetailViewModel {
	struct UIInputs {
		let moreInformation: Observable<Void>
		let share: Observable<UIBarButtonItem>
	}

	// UI outputs
	let depth: Driver<String>
	let distance: Driver<String>
	let magnitudeString: Driver<String>
	let magnitudeColor: Driver<UIColor>
	let coordinate: Driver<CLLocationCoordinate2D>
	let name: Driver<String>
	let time: Driver<String>

	// coordinator outputs
	let presentURL: Driver<URL>
	let presentAlert: Driver<(title: String, message: String)>
	let share: Driver<ShareInfo>
}

extension EarthquakeDetailViewModel {
	init(_ inputs: UIInputs, earthquake: Observable<Earthquake>, userLocation: Observable<CLLocation>) {

		let weblink = inputs.moreInformation
			.withLatestFrom(earthquake)
			.map { $0.weblink }

		depth = earthquake
			.map { depthFormatter.string(fromMeters: $0.depth) }
			.asDriverLogError()

		distance = Observable.combineLatest(earthquake, userLocation)
			.map { $1.distance(from: $0.location) }
			.map { distanceFormatter.string(fromMeters: $0) }
			.asDriverLogError()

		magnitudeString = earthquake
			.map { $0.magnitude }
			.compactMap { magnitudeFormatter.string(from: $0 as NSNumber) }
			.asDriverLogError()

		magnitudeColor = earthquake
			.map {
				switch $0.magnitude {
				case 0..<3:
					return UIColor.gray
				case 3..<4:
					return UIColor.blue
				case 4..<5:
					return UIColor.orange
				default:
					return UIColor.red
				}
			}
			.asDriverLogError()

		coordinate = earthquake
			.map { $0.coordinate }
			.distinctUntilChanged { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
			.asDriverLogError()

		name = earthquake
			.map { $0.name }
			.asDriverLogError()

		time = earthquake
			.map { $0.timestamp }
			.map { timestampFormatter.string(from: $0) }
			.asDriverLogError()

		presentURL = weblink
			.compactMap { $0 }
			.asDriverLogError()

		presentAlert = weblink
			.filter { $0 == nil }
			.map { _ in (title: "No Information", message: "No other information is available for this earthquake") }
			.asDriverLogError()

		share = inputs.share
			.withLatestFrom(earthquake) { ($0, $1) }
			.map { (barButtonItem, earthquake) -> ShareInfo in
				if let url = earthquake.weblink {
					return ShareInfo(items: [url, earthquake.location], barButtonItem: barButtonItem)
				}
				else {
					return ShareInfo(items: [earthquake.location], barButtonItem: barButtonItem)
				}
			}
			.asDriverLogError()
	}
}

struct ShareInfo {
	let items: [Any]
	let barButtonItem: UIBarButtonItem?
}

private
let depthFormatter: LengthFormatter = {
	let result = LengthFormatter()
	result.isForPersonHeightUse = false
	return result
}()

private
let distanceFormatter: LengthFormatter = {
	let result = LengthFormatter()
	result.isForPersonHeightUse = false
	result.numberFormatter.maximumFractionDigits = 2
	return result
}()

private
let magnitudeFormatter: NumberFormatter = {
	let result = NumberFormatter()
	result.numberStyle = .decimal
	result.maximumFractionDigits = 1
	result.minimumFractionDigits = 1
	return result
}()

private
let timestampFormatter: DateFormatter = {
	let timestampFormatter = DateFormatter()

	timestampFormatter.dateStyle = .medium
	timestampFormatter.timeStyle = .medium

	return timestampFormatter
}()
