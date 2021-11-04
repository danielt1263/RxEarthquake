//
//  EarthquakeDetailConnections.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import MapKit
import RxCocoa
import RxSwift
import SafariServices
import UIKit

extension EarthquakeDetailViewController {
	func connect(earthquake: Earthquake) {
		
		let span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
		let annotation = MKPointAnnotation().setup {
			$0.coordinate = earthquake.coordinate
		}
		
		mapView.region = MKCoordinateRegion(center: earthquake.coordinate, span: span)
		mapView.addAnnotation(annotation)
		
		nameLabel.text = earthquake.name
		magnitudeLabel.text = EarthquakeDetailLogic.magnitude(earthquake: earthquake)
		depthLabel.text = EarthquakeDetailLogic.depth(earthquake: earthquake)
		timeLabel.text = EarthquakeDetailLogic.time(earthquake: earthquake)
		
		EarthquakeDetailLogic.distance(
			earthquake: earthquake,
			authorization: locationManager.rx.didChangeAuthorizationStatus,
			userLocations: locationManager.rx.didUpdateLocations
		)
			.bind(to: distanceLabel.rx.text)
			.disposed(by: disposeBag)
		
		EarthquakeDetailLogic.presentSafari(
			earthquake: earthquake,
			itemSelected: tableView.rx.itemSelected.asObservable()
		)
			.bind(onNext: presentScene(animated: true) { url in
				SFSafariViewController(url: url).scene { _ in
					Observable<Never>.never() }
			})
			.disposed(by: disposeBag)
		
		EarthquakeDetailLogic.presentAlert(
			earthquake: earthquake,
			itemSelected: tableView.rx.itemSelected.asObservable()
		)
			.bind(onNext: presentScene(animated: true) { title, message in
				UIAlertController(title: title, message: message, preferredStyle: .alert)
					.scene { $0.connectOK() }
			})
			.disposed(by: disposeBag)
		
		EarthquakeDetailLogic.presentShare(
			earthquake: earthquake,
			shareTrigger: shareButton.rx.tap.asObservable()
		)
			.bind(onNext: presentScene(animated: true, over: shareButton) { items in
				UIActivityViewController(activityItems: items, applicationActivities: nil)
					.scene { _ in Observable<Never>.never() }
			})
			.disposed(by: disposeBag)
	}
}

extension Reactive where Base: MKMapView {
	var focusMap: Binder<CLLocationCoordinate2D> {
		Binder(base) { mapView, coordinate in
			let span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			mapView.region = MKCoordinateRegion(center: coordinate, span: span)
			mapView.removeAnnotations(mapView.annotations)
			mapView.addAnnotation(annotation)
		}
	}
}

struct ShareInfo {
	let items: [Any]
	let barButtonItem: Any
}
