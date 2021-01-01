//
//  EarthquakeDetailLogic.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/7/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.//
//

import Foundation
import RxSwift
import CoreLocation

enum EarthquakeDetailLogic {

	static func name(earthquake: Observable<Earthquake>) -> Observable<String> {
		earthquake
			.map { $0.name }
	}

	static func magnitude(earthquake: Observable<Earthquake>) -> Observable<String> {
		earthquake
			.map { $0.magnitude }
			.compactMap { magnitudeFormatter.string(from: $0 as NSNumber) }
	}

	static func depth(earthquake: Observable<Earthquake>) -> Observable<String> {
		earthquake
			.map { depthFormatter.string(fromMeters: $0.depth) }
	}

	static func time(earthquake: Observable<Earthquake>) -> Observable<String> {
		earthquake
			.map { $0.timestamp }
			.map { timestampFormatter.string(from: $0) }
	}

	static func distance(earthquake: Observable<Earthquake>, userLocation: Observable<CLLocation>) -> Observable<String> {
		Observable.combineLatest(earthquake, userLocation)
			.map { $1.distance(from: $0.location) }
			.map { distanceFormatter.string(fromMeters: $0) }
	}

	static func presentAlert(itemSelected: Observable<IndexPath>, earthquake: Observable<Earthquake>) -> Observable<(title: String, message: String)> {
		weblink(itemSelected: itemSelected, earthquake: earthquake)
			.filter { $0 == nil }
			.map(to: ())
			.map { (title: "No Information", message: "No other information is available for this earthquake") }
	}

	static func presentSafari(itemSelected: Observable<IndexPath>, earthquake: Observable<Earthquake>) -> Observable<URL> {
		weblink(itemSelected: itemSelected, earthquake: earthquake)
			.compactMap { $0 }
	}

	static func presentShare(shareTrigger: Observable<Void>, earthquake: Observable<Earthquake>, shareButton: @escaping () -> Any?) -> Observable<ShareInfo> {
		shareTrigger
			.compactMap(shareButton)
			.withLatestFrom(earthquake) { ($0, $1) }
			.map { (barButtonItem, earthquake) -> ShareInfo in
				if let url = earthquake.weblink {
					return ShareInfo(items: [url, earthquake.location], barButtonItem: barButtonItem)
				}
				else {
					return ShareInfo(items: [earthquake.location], barButtonItem: barButtonItem)
				}
			}
	}
}

private func weblink(itemSelected: Observable<IndexPath>, earthquake: Observable<Earthquake>) -> Observable<URL?> {
	itemSelected
		.filter { $0.section == 1 && $0.row == 0 }
		.map(to: ())
		.withLatestFrom(earthquake)
		.map { $0.weblink }
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
