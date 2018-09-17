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
	let longitude: Double
	let latitude: Double
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
		guard let geometry = feature["geometry"] as? [String: AnyObject] else { return nil }
		guard let coordinates = geometry["coordinates"] as? [Double], coordinates.count > 2 else { return nil }
		guard let properties = feature["properties"] as? [String: AnyObject] else { return nil }
		guard let place = properties["place"] as? String else { return nil }
		guard let mag = properties["mag"] as? Double else { return nil }
		guard let time = properties["time"] as? Double else { return nil }
		id = ID(rawValue: earthquakeID)
		longitude = coordinates[0]
		latitude = coordinates[1]
		depth = coordinates[2] * 1000 // `depth` is in km, but we want to store it in meters.
		magnitude = mag
		name = place
		timestamp = Date(timeIntervalSince1970: time / 1000)
		weblink = properties["url"] as? String ?? ""
	}
}

struct Identifier<T>: RawRepresentable {
	let rawValue: String
}
