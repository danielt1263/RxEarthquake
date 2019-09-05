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

final class Coordinator {

	init(splitViewController: UISplitViewController) {
		let mainNav = splitViewController.children[0] as! UINavigationController
		let main = mainNav.children[0] as! EarthquakeListViewController
		let detailNav = splitViewController.children[1] as! UINavigationController
		let detail = detailNav.children[0] as! EarthquakeDetailViewController

		let displayEarthquake = main.installOutputViewModel(outputFactory: EarthquakeList.viewModel(dataTask: dataTask))
			.share(replay: 1)
		let detailAction = detail.installOutputViewModel(
			outputFactory: EarthquakeDetail.viewModel(
				earthquake: displayEarthquake,
				userLocation: locationManager.userLocation
			)
		)

		displayEarthquake
			.map { _ in }
			.bind {
				splitViewController.showDetailViewController(detailNav, sender: self)
			}
			.disposed(by: bag)

		displayEarthquake
			.bind(to: selectedEarthquake)
			.disposed(by: bag)

		detailAction
			.bind(onNext: { action in
				switch action {
				case .presentURL(let url):
					presentSafariViewController(url: url)
				case .presentAlert(let title, let message):
					presentAlertViewController(title: title, message: message)
				case .share(let shareInfo):
					presentActivityViewController(shareInfo: shareInfo)
				}
			})
			.disposed(by: bag)

		splitViewController.delegate = self
		splitViewController.preferredDisplayMode = .allVisible
	}

	private let locationManager = LocationManager()
	private let selectedEarthquake = BehaviorRelay<Earthquake?>(value: nil)
	private let bag = DisposeBag()

}

extension Coordinator: UISplitViewControllerDelegate {
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return selectedEarthquake.value == nil
	}
}

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
