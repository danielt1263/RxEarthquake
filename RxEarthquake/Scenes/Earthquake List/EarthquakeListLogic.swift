//
//  EarthquakeListLogic.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/14/20.
//  Copyright © 2020 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift

enum EarthquakeListLogic {

	static func request(refreshTrigger: Observable<Void>, appearTrigger: Observable<[Any]>) -> Observable<URLRequest> {
		Observable.merge(
			refreshTrigger,
			appearTrigger.map { _ in }
		)
			.map { earthquakeSummary }
	}

	static func cellData(earthquakeData: Observable<Data>) -> Observable<[EarthquakeCellDisplay]> {
		earthquakeData
			.map { Earthquake.earthquakes(from: $0) }
			.map { $0.map { EarthquakeCellDisplay(earthquake: $0) } }
	}

	static func chooseEarthquake(trigger: Observable<IndexPath>, earthquakeData: Observable<Data>) -> Observable<Earthquake> {
		trigger
			.withLatestFrom(earthquakeData.map { Earthquake.earthquakes(from: $0) }) { $1[$0.row] }
	}
}

private let earthquakeSummary: URLRequest = {
	let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
	return URLRequest(url: url)
}()

private extension EarthquakeCellDisplay {
	init(earthquake: Earthquake) {
		place = earthquake.name
		date = timestampFormatter.string(from: earthquake.timestamp)
		magnitude = magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude)) ?? ""
		switch earthquake.magnitude {
		case 0..<2:
			imageName = ""
		case 2..<3:
			imageName = "2.0"
		case 3..<4:
			imageName = "3.0"
		case 4..<5:
			imageName = "4.0"
		default:
			imageName = "5.0"
		}
	}
}

private let timestampFormatter: DateFormatter = {
	let timestampFormatter = DateFormatter()

	timestampFormatter.dateStyle = .medium
	timestampFormatter.timeStyle = .medium

	return timestampFormatter
}()

private let magnitudeFormatter: NumberFormatter = {
	let magnitudeFormatter = NumberFormatter()

	magnitudeFormatter.numberStyle = .decimal
	magnitudeFormatter.maximumFractionDigits = 1
	magnitudeFormatter.minimumFractionDigits = 1

	return magnitudeFormatter
}()
