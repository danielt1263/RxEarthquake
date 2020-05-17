//
//  EarthquakeDetailViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/16/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift
import MapKit

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
