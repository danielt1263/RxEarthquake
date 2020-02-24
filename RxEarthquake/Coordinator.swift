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
		.share(replay: 1)

	_ = detail.installOutputViewModel(
		outputFactory: EarthquakeDetail.viewModel(
			earthquake: displayEarthquake,
			userLocation: locationManager.userLocation
		)
	)
		.bind { action in
			switch action {
			case .presentURL(let url):
				presentSafariViewController(url: url)
			case .presentAlert(let title, let message):
				presentAlertViewController(title: title, message: message)
			case .share(let shareInfo):
				presentActivityViewController(shareInfo: shareInfo)
			}
		}

	_ = displayEarthquake
		.map { _ in }
		.bind {
			splitViewController.showDetailViewController(detailNav, sender: nil)
		}

	_ = displayEarthquake.map { _ in false }
		.startWith(true)
		.bind(to: splitViewController.rx.collapseSecondaryOntoPrimary)

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

extension UISplitViewController: HasDelegate {
    public typealias Delegate = UISplitViewControllerDelegate
}

class LayoutDelegateProxy
    : DelegateProxy<UISplitViewController, UISplitViewControllerDelegate>
    , DelegateProxyType
    , UISplitViewControllerDelegate {

    init(parentObject: UISplitViewController) {
        super.init(parentObject: parentObject, delegateProxy: LayoutDelegateProxy.self)
    }

    deinit {
        _collapseSecondaryOntoPrimary.onCompleted()
    }

    public static func registerKnownImplementations() {
        self.register { LayoutDelegateProxy(parentObject: $0) }
    }

	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return try! _collapseSecondaryOntoPrimary.value()
	}

	fileprivate let _collapseSecondaryOntoPrimary = BehaviorSubject<Bool>(value: false)
}

extension Reactive where Base: UISplitViewController {
    var delegate: LayoutDelegateProxy {
        return LayoutDelegateProxy.proxy(for: base)
    }

	func collapseSecondaryOntoPrimary<Source: ObservableType>(_ source: Source) -> Disposable where Source.Element == Bool {
		return source
			.bind(to: delegate._collapseSecondaryOntoPrimary)
	}
}
