//
//  EarthquakeListViewController.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/2/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift
import RxCocoa

final class EarthquakeListViewController: UITableViewController, HasViewModel {

	var viewModelFactory: (EarthquakeList.UIInputs) -> EarthquakeList.UIOutputs = { _ in fatalError("Must provide factory function first.") }

	override func viewDidLoad() {
		super.viewDidLoad()

		self.clearsSelectionOnViewWillAppear = false
		let refreshControl = self.refreshControl!

		let inputs = EarthquakeList.UIInputs(
			selectEarthquake: tableView.rx.itemSelected.asObservable(),
			refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
			viewAppearTrigger: rx.methodInvoked(#selector(viewDidAppear(_:))).map { _ in }
		)

		let viewModel = viewModelFactory(inputs)

		tableView.dataSource = nil
		tableView.delegate = nil
		viewModel.earthquakeCellViewModels
			.drive(tableView.rx.items(cellIdentifier: "EarthquakeCell", cellType: EarthquakeTableViewCell.self)) { index, viewModel, cell in
				cell.configure(viewModel: viewModel)
			}
			.disposed(by: bag)

		viewModel.endRefreshing
			.drive(onNext: {
				refreshControl.endRefreshing()
			})
			.disposed(by: bag)
	}

	let bag = DisposeBag()
}

