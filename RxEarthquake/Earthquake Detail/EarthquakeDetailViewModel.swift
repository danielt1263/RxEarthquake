//
//  EarthquakeDetailViewModel.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/7/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

enum MoreInformation {
	case url(URL)
	case alert(title: String, message: String)

	var url: URL? {
		if case let .url(url) = self {
			return url
		}
		return nil
	}

	var alert: (title: String, message: String)? {
		if case let .alert(title, message) = self {
			return (title, message)
		}
		return nil
	}
}

struct ShareInfo {
	let items: [Any]
	let barButtonItem: UIBarButtonItem?
}

class EarthquakeDetailViewModel {
	struct UIInputs {
		let moreInformation: Observable<Void>
		let share: Observable<UIBarButtonItem>
	}

	// UI outputs
	let depth: Driver<String>
	let distance: Driver<String>
	let magnitudeString: Driver<String>
	let magnitudeDecimal: Driver<Double>
	let coordinate: Driver<CLLocationCoordinate2D>
	let name: Driver<String>
	let time: Driver<String>

	// coordinator outputs
	let moreInformation: Driver<MoreInformation>
	let share: Driver<ShareInfo>

	init(_ inputs: UIInputs, earthquake: Observable<Earthquake>, userLocation: Observable<CLLocation>) {

		depth = earthquake.map { depthFormatter.string(fromMeters: $0.depth) }
			.asDriverLogError()

		distance = Observable.combineLatest(earthquake, userLocation)
			.map { $1.distance(from: $0.location) }
			.map { distanceFormatter.string(fromMeters: $0) }
			.asDriverLogError()

		magnitudeString = earthquake
			.map { $0.magnitude }
			.map { magnitudeFormatter.string(from: $0 as NSNumber) }
			.unwrap()
			.asDriverLogError()

		magnitudeDecimal = earthquake
			.map { $0.magnitude }
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

		moreInformation = inputs.moreInformation
			.withLatestFrom(earthquake)
			.map { $0.weblink }
			.map { URL(string: $0) }
			.map { $0 != nil ? MoreInformation.url($0!) : MoreInformation.alert(title: "No Information", message: "No other information is available for this earthquake") }
			.asDriverLogError()

		share = inputs.share
			.withLatestFrom(earthquake) { ($0, $1) }
			.map { (barButtonItem, earthquake) -> ShareInfo in
				if let url = URL(string: earthquake.weblink) {
					return ShareInfo(items: [url, earthquake.location], barButtonItem: barButtonItem)
				}
				else {
					return ShareInfo(items: [earthquake.location], barButtonItem: barButtonItem)
				}
			}
			.asDriverLogError()
	}
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
