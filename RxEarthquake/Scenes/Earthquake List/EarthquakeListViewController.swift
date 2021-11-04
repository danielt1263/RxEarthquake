//
//  EarthquakeListViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import RxSwift
import UIKit

final class EarthquakeListViewController: UITableViewController {

	let disposeBag = DisposeBag()
}

final class EarthquakeTableViewCell: UITableViewCell {

	@IBOutlet weak var placeLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var magnitudeImageView: UIImageView!
	@IBOutlet weak var magnitudeLabel: UILabel!
}
