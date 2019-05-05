//
//  Earthquake.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/2/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import CoreLocation

struct Earthquake {
	typealias ID = Identifier<Earthquake>
	let id: ID
	let coordinate: CLLocationCoordinate2D
	let depth: Double
	let magnitude: Double
	let name: String
	let timestamp: Date
	let weblink: URL?
	let location: CLLocation
}

extension Earthquake {
	static func earthquakes(from data: Data) -> [Earthquake] {
		let earthquakeSummary = try? JSONDecoder().decode(EarthquakeSummary.self, from: data)
		return earthquakeSummary?.features.map(Earthquake.init(feature:)) ?? []
	}

	private init(feature: Feature) {
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

struct Identifier<T>: RawRepresentable {
	let rawValue: String
}

private struct EarthquakeSummary: Decodable {
	let features: [Feature]
}

private struct Feature: Decodable {
	let geometry: Geometry
	let properties: Properties
	let id: String
}

private struct Geometry: Decodable {
	let coordinates: [Double]
}

private struct Properties: Decodable {
	let mag: Double
	let place: String
	let time: Double
	let url: URL?
}
