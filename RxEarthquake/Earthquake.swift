//
//  Earthquake.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import CoreLocation
import Foundation

struct Earthquake: Identifiable {
	let id: Identifier<String, Earthquake>
	let coordinate: CLLocationCoordinate2D
	let depth: Double
	let magnitude: Double
	let name: String
	let timestamp: Date
	let weblink: URL?
	let location: CLLocation
}

extension Earthquake {
	static func earthquakes(from earthquakeSummary: EarthquakeSummary) throws -> [Earthquake] {
		return earthquakeSummary.features.map { Earthquake(feature: $0) }
	}

	private init(feature: EarthquakeSummary.Feature) {
		id = ID(rawValue: feature.id)
		coordinate = CLLocationCoordinate2D(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0])
		depth = feature.geometry.coordinates[2] * 1000
		magnitude = feature.properties.mag
		name = feature.properties.place
		timestamp = Date(timeIntervalSince1970: feature.properties.time/1000.0)
		weblink = feature.properties.url
		location = CLLocation(coordinate: coordinate, altitude: -depth, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
	}
}

