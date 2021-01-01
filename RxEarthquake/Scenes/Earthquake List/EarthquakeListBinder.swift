//
//  EarthquakeListBinder.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 5/14/20.
//	Copyright © 2020 Daniel Tartaglia. MIT License.
//

import RxCocoa
import RxSwift
import UIKit

extension EarthquakeListViewController {
	func bind() -> Observable<Earthquake> {
		loadViewIfNeeded()

		let activityIndicator = ActivityIndicator()
		let errorRouter = PublishSubject<Error>()

		let earthquakeData = EarthquakeListLogic.request(
			refreshTrigger: refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
			appearTrigger: rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
		)
			.flatMapLatest { request in
				URLSession.shared.rx.data(request: request)
					.trackActivity(activityIndicator)
					.rerouteError(errorRouter.asObserver())
			}
			.share(replay: 1)

		tableView.dataSource = nil
		EarthquakeListLogic.cellData(earthquakeData: earthquakeData)
			.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: EarthquakeTableViewCell.self)) { _, element, cell in
				cell.placeLabel.text = element.place
				cell.dateLabel.text = element.date
				cell.magnitudeLabel.text = element.magnitude
				cell.magnitudeImageView.image = element.imageName.isEmpty ? UIImage() : UIImage(named: element.imageName)
			}
			.disposed(by: disposeBag)

		activityIndicator.asObservable()
			.bind(to: refreshControl!.rx.isRefreshing)
			.disposed(by: disposeBag)

		activityIndicator.asObservable()
			.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
			.bind { isOn in
				UIApplication.shared.isNetworkActivityIndicatorVisible = isOn
			}
			.disposed(by: disposeBag)

		errorRouter.asObservable()
			.map { (title: "Error", message: $0.localizedDescription) }
			.bind { title, message in
				finalPresentScene(animated: true) {
					UIAlertController(title: title, message: message, preferredStyle: .alert).scene { $0.connectOK() }
				}
			}
			.disposed(by: disposeBag)

		return EarthquakeListLogic.chooseEarthquake(
			trigger: tableView.rx.itemSelected.asObservable(),
			earthquakeData: earthquakeData
		)
	}
}

struct EarthquakeCellDisplay {
	let place: String
	let date: String
	let magnitude: String
	let imageName: String
}
