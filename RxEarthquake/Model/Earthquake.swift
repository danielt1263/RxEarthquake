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
	let latitude: Double
	let longitude: Double
	let depth: Double
	let magnitude: Double
	let name: String
	let timestamp: Date
	let weblink: String

	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}

	var location: CLLocation {
		return CLLocation(coordinate: coordinate, altitude: -depth, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
	}
}

extension Earthquake {
	static func earthquakes(from data: Data) -> [Earthquake] {
		return (try? JSONSerialization.jsonObject(with: data, options: []))
			.flatMap { $0 as? [String: Any] }
			.flatMap { $0["features"] as? [[String: Any]] }
			.flatMap { $0.compactMap { Earthquake(feature: $0) } } ?? []
	}

	init?(feature: [String: Any]) {
		guard let earthquakeID = feature["id"] as? String, !earthquakeID.isEmpty else { return nil }
		id = ID(rawValue: earthquakeID)

		let geometry = feature["geometry"] as? [String: AnyObject] ?? [:]
		if let coordinates = geometry["coordinates"] as? [Double], coordinates.count == 3 {
			longitude = coordinates[0]
			latitude = coordinates[1]
			// `depth` is in km, but we want to store it in meters.
			depth = coordinates[2] * 1000
		}
		else {
			longitude = 0
			latitude = 0
			depth = 0
		}

		let properties = feature["properties"] as? [String: AnyObject] ?? [:]

		name = properties["place"] as? String ?? ""
		weblink = properties["url"] as? String ?? ""
		magnitude = properties["mag"] as? Double ?? 0.0

		if let offset = properties["time"] as? Double {
			timestamp = Date(timeIntervalSince1970: offset / 1000)
		}
		else {
			timestamp = Date.distantFuture
		}
	}
}

struct Identifier<T>: RawRepresentable {
	let rawValue: String
}

