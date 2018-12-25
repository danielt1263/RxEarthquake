//
//  EarthquakeTableViewCell.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/2/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit

class EarthquakeTableViewCell: UITableViewCell {
	@IBOutlet var locationLabel: UILabel!
	@IBOutlet var timestampLabel: UILabel!
	@IBOutlet var magnitudeLabel: UILabel!
	@IBOutlet var magnitudeImage: UIImageView!

	func configure(viewModel: EarthquakeCellViewModel) {
		locationLabel.text = viewModel.location
		timestampLabel.text = viewModel.timestamp
		magnitudeLabel.text = viewModel.magnitude
		magnitudeImage.image = viewModel.magnitudeImage
	}
}
