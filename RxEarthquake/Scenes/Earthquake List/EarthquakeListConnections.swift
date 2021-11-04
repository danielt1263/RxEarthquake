//
//  EarthquakeListConnections.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on September 8, 2018.
//  Copyright © 2021 Daniel Tartaglia. MIT License.
//

import Cause_Logic_Effect
import Foundation
import RxSwift
import UIKit

extension EarthquakeListViewController {
	func connect() -> Observable<Earthquake> {
		let api = API()
		
		let earthquakes = EarthquakeListLogic.request(
			refreshTrigger: refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
			appearTrigger: rx.viewDidAppear
		)
			.flatMapLatest { endpoint in
				api.response(endpoint)
			}
			.share(replay: 1)
		
		title = "Earthquakes"

		tableView.dataSource = nil
		EarthquakeListLogic.cellData(earthquakeData: earthquakes)
			.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: EarthquakeTableViewCell.self)) { _, element, cell in
				cell.placeLabel.text = element.place
				cell.dateLabel.text = element.date
				cell.magnitudeLabel.text = element.magnitude
				cell.magnitudeImageView.image = element.imageName.isEmpty ? UIImage() : UIImage(named: element.imageName)
			}
			.disposed(by: disposeBag)
		
		api.isActive
			.bind(to: refreshControl!.rx.isRefreshing)
			.disposed(by: disposeBag)
		
		api.error
			.map { (title: "Error", message: $0.localizedDescription) }
			.bind(onNext: presentScene(animated: true) { title, message in
				UIAlertController(title: title, message: message, preferredStyle: .alert).scene { $0.connectOK() }
			})
			.disposed(by: disposeBag)
		
		return EarthquakeListLogic.chooseEarthquake(
			trigger: tableView.rx.itemSelected.asObservable(),
			earthquakes: earthquakes
		)
	}
}
