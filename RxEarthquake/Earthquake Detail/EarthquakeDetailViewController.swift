//
//  EarthquakeDetailViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/2/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class EarthquakeDetailViewController: UITableViewController {

	@IBOutlet weak var depthLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var magnitudeLabel: UILabel!
	@IBOutlet weak var map: MKMapView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var shareButton: UIBarButtonItem!

	var viewModelFactory: (EarthquakeDetailViewModel.UIInputs) -> EarthquakeDetailViewModel = { _ in fatalError("Must provide factory function first.") }

	override func viewDidLoad() {
		super.viewDidLoad()

		let tableView = self.tableView!
		let shareButton = self.shareButton!
		let inputs = EarthquakeDetailViewModel.UIInputs(
			moreInformation: tableView.rx.itemSelected
				.do(onNext: { tableView.deselectRow(at: $0, animated: true) })
				.filter { $0.section == 1 && $0.row == 0 }
				.map { _ in },
			share: shareButton.rx.tap.map { shareButton }
		)
		let viewModel = viewModelFactory(inputs)

		viewModel.depth
			.drive(depthLabel.rx.text)
			.disposed(by: bag)

		viewModel.distance
			.drive(distanceLabel.rx.text)
			.disposed(by: bag)

		viewModel.magnitudeString
			.drive(magnitudeLabel.rx.text)
			.disposed(by: bag)

		viewModel.magnitudeColor
			.drive(magnitudeColor)
			.disposed(by: bag)

		viewModel.name
			.drive(nameLabel.rx.text)
			.disposed(by: bag)

		viewModel.time
			.drive(timeLabel.rx.text)
			.disposed(by: bag)

		let map = self.map!
		viewModel.coordinate
			.drive(onNext: { coordinate in
				let span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
				map.region = MKCoordinateRegion(center: coordinate, span: span)

				let annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				map.removeAnnotations(map.annotations)
				map.addAnnotation(annotation)
			})
			.disposed(by: bag)
	}

	private let magnitudeColor = BehaviorRelay<UIColor>(value: .red)
	private let bag = DisposeBag()
}

extension EarthquakeDetailViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let pin = (mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView) ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
		pin.pinTintColor = magnitudeColor.value
		pin.isEnabled = false
		return pin
	}
}
