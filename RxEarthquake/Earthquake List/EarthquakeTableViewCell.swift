/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A UITableViewCell to display the high-level information of an earthquake
*/

import UIKit

class EarthquakeTableViewCell: UITableViewCell {
	// MARK: Properties

	@IBOutlet var locationLabel: UILabel!
	@IBOutlet var timestampLabel: UILabel!
	@IBOutlet var magnitudeLabel: UILabel!
	@IBOutlet var magnitudeImage: UIImageView!

	// MARK: Configuration

	func configure(viewModel: EarthquakeCellViewModel) {
		locationLabel.text = viewModel.location
		timestampLabel.text = viewModel.timestamp
		magnitudeLabel.text = viewModel.magnitude
		magnitudeImage.image = viewModel.magnitudeImage
	}
}
