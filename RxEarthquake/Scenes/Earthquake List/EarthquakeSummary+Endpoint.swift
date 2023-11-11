//
//  EarthquakeSummary+Endpoint.swift
//  RxEarthquake
//
//  Created by Daniel on 11/11/23.
//

import Cause_Logic_Effect
import Foundation

extension Endpoint where Response == EarthquakeSummary {
	static let earthquakeSummary: Endpoint = {
		let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
		return Endpoint(
			request: URLRequest(url: url),
			decoder: JSONDecoder()
		)
	}()
}

struct EarthquakeSummary: Decodable {
	struct Feature: Decodable {
		struct Geometry: Decodable {
			let coordinates: [Double]
		}

		struct Properties: Decodable {
			let mag: Double
			let place: String
			let time: Double
			let url: URL?
		}

		let geometry: Geometry
		let properties: Properties
		let id: String
	}

	let features: [Feature]
}

