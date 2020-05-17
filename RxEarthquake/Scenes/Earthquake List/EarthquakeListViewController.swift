//
//  EarthquakeListViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/14/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift

final class EarthquakeListViewController: UITableViewController {

	let disposeBag = DisposeBag()
}

final class EarthquakeTableViewCell: UITableViewCell {

	@IBOutlet weak var placeLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var magnitudeImageView: UIImageView!
	@IBOutlet weak var magnitudeLabel: UILabel!
}
