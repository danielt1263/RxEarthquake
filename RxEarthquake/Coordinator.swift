//
//  Coordinator.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/6/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import SafariServices

func coordinator(splitViewController: UISplitViewController) {
	let mainNav = splitViewController.children[0] as! UINavigationController
	let main = mainNav.children[0] as! EarthquakeListViewController
	let detailNav = splitViewController.children[1] as! UINavigationController
	let detail = detailNav.children[0] as! EarthquakeDetailViewController

	let displayEarthquake = main.installOutputViewModel(outputFactory: EarthquakeList.viewModel(dataTask: dataTask))

	_ = detail.installOutputViewModel(
		outputFactory: EarthquakeDetail.viewModel(
			earthquake: displayEarthquake,
			userLocation: locationManager.userLocation
		)
	)
		.drive(onNext: { action in
			switch action {
			case .presentURL(let url):
				presentSafariViewController(url: url)
			case .presentAlert(let title, let message):
				presentAlertViewController(title: title, message: message)
			case .share(let shareInfo):
				presentActivityViewController(shareInfo: shareInfo)
			}
		})

	_ = displayEarthquake
		.map { _ in }
		.drive(onNext: {
			splitViewController.showDetailViewController(detailNav, sender: nil)
		})

	_ = displayEarthquake.map { _ in false }
		.startWith(true)
		.drive(splitViewController.rx.collapseSecondaryOntoPrimary)

	splitViewController.preferredDisplayMode = .allVisible
}

private
let locationManager = LocationManager()

private
func presentSafariViewController(url: URL) {
	let safari = SFSafariViewController(url: url)
	UIViewController.top().present(safari, animated: true)
}

private
func presentAlertViewController(title: String, message: String) {
	let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
	alert.addAction(UIAlertAction(title: "OK", style: .default))
	UIViewController.top().present(alert, animated: true)
}

private
func presentActivityViewController(shareInfo: ShareInfo) {
	let shareSheet = UIActivityViewController(activityItems: shareInfo.items, applicationActivities: nil)
	shareSheet.popoverPresentationController?.barButtonItem = shareInfo.barButtonItem
	UIViewController.top().present(shareSheet, animated: true)
}
