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
import RxEnumKit
import CoreLocation

enum EarthquakeDetail {
	struct UIInputs {
		let moreInformation: Driver<Void>
		let share: Driver<UIBarButtonItem>
	}

	struct UIOutputs {
		let depth: Driver<String>
		let distance: Driver<String>
		let magnitudeString: Driver<String>
		let magnitudeColor: Driver<UIColor>
		let coordinate: Driver<CLLocationCoordinate2D>
		let name: Driver<String>
		let time: Driver<String>
	}

	enum Action {
		case presentURL(URL)
		case presentAlert(title: String, message: String)
		case share(ShareInfo)
	}

	static func viewModel(earthquake: Driver<Earthquake>, userLocation: Observable<CLLocation>) -> (UIInputs) -> (UIOutputs, Driver<Action>) {
		return { inputs in

			let location = userLocation
				.asDriverResult()

			let weblink = inputs.moreInformation
				.withLatestFrom(earthquake)
				.map { $0.weblink }

			let depth = earthquake
				.map { depthFormatter.string(fromMeters: $0.depth) }

			let distance = Driver.combineLatest(earthquake, location.capture(case: Result.success))
				.map { $1.distance(from: $0.location) }
				.map { distanceFormatter.string(fromMeters: $0) }

			let magnitudeString = earthquake
				.map { $0.magnitude }
				.compactMap { magnitudeFormatter.string(from: $0 as NSNumber) }

			let magnitudeColor: Driver<UIColor> = earthquake
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

			let coordinate = earthquake
				.map { $0.coordinate }
				.distinctUntilChanged { $0.latitude == $1.latitude && $0.longitude == $1.longitude }

			let name = earthquake
				.map { $0.name }

			let time = earthquake
				.map { $0.timestamp }
				.map { timestampFormatter.string(from: $0) }

			let presentURL = weblink
				.compactMap { $0 }
				.map(Action.presentURL)

			let error = location
				.capture(case: Result.failure)
				.map { (title: "Error", message: "There was an iOS system error. The location system is not available. \($0.localizedDescription)") }
				.map(Action.presentAlert)

			let presentAlert = weblink
				.filter { $0 == nil }
				.map { _ in (title: "No Information", message: "No other information is available for this earthquake") }
				.map(Action.presentAlert)

			let share = inputs.share
				.withLatestFrom(earthquake) { ($0, $1) }
				.map { (barButtonItem, earthquake) -> ShareInfo in
					if let url = earthquake.weblink {
						return ShareInfo(items: [url, earthquake.location], barButtonItem: barButtonItem)
					}
					else {
						return ShareInfo(items: [earthquake.location], barButtonItem: barButtonItem)
					}
				}
				.map(Action.share)

			return (
				UIOutputs(depth: depth, distance: distance, magnitudeString: magnitudeString, magnitudeColor: magnitudeColor, coordinate: coordinate, name: name, time: time),
				Driver.merge(presentURL, presentAlert, share, error)
			)
		}
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
