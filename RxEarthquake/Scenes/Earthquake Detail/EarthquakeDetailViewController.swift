//
//  EarthquakeDetailViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import MapKit
import RxSwift
import UIKit

final class EarthquakeDetailViewController: UITableViewController {
	
	@IBOutlet weak var depthLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var magnitudeLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var timeLabel: UILabel!

	let disposeBag = DisposeBag()
}
