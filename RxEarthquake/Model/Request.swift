//
//  Request.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/4/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation


extension URLRequest {
	static let earthquakeSummary: URLRequest = {
		let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
		return URLRequest(url: url)
	}()
}
