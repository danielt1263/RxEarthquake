//
//  EarthquakeListLogic.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import Foundation
import RxSwift

enum EarthquakeListLogic {

	static func request(refreshTrigger: Observable<Void>, appearTrigger: Observable<Bool>) -> Observable<Endpoint<[Earthquake]>> {
		Observable.merge(
			refreshTrigger,
			appearTrigger.map(to: ())
		)
			.map { .earthquakeSummary }
	}

	static func cellData(earthquakeData: Observable<[Earthquake]>) -> Observable<[EarthquakeCellDisplay]> {
		earthquakeData
			.map { $0.map { EarthquakeCellDisplay(earthquake: $0) } }
	}

	static func chooseEarthquake(trigger: Observable<IndexPath>, earthquakes: Observable<[Earthquake]>) -> Observable<Earthquake> {
		trigger
			.withLatestFrom(earthquakes) { $1[$0.row] }
	}
}

extension Endpoint where T == [Earthquake] {
	fileprivate static let earthquakeSummary: Endpoint = {
		let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
		return Endpoint(
			request: URLRequest(url: url),
			response: Earthquake.earthquakes(from:)
		)
	}()
}

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
