//
//  EarthquakeListViewModel.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/4/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import RxCocoa
import RxEnumKit

enum EarthquakeList {
	struct UIInputs {
		let selectEarthquake: Driver<IndexPath>
		let refreshTrigger: Driver<Void>
		let viewAppearTrigger: Observable<Void>
	}

	struct UIOutputs {
		let earthquakeCellViewModels: Driver<[EarthquakeCellViewModel]>
		let endRefreshing: Driver<Void>
		let errorMessage: Driver<String>
	}

	static func viewModel(dataTask: @escaping DataTask, scheduler: SchedulerType = MainScheduler.instance) -> (UIInputs) -> (UIOutputs, Driver<Earthquake>) {
		return { inputs in
			let viewAppearTrigger = inputs.viewAppearTrigger
				.asDriverResult()

			let networkResponse = Driver.merge(inputs.refreshTrigger, viewAppearTrigger.capture(case: Result.success))
				.map { URLRequest.earthquakeSummary }
				.flatMapLatest { dataTask($0) }

			let error = networkResponse
				.capture(case: Result.failure)
				.map { $0.localizedDescription }

			let internalError = viewAppearTrigger
				.capture(case: Result.failure)
				.map { "There was an internal iOS error. Please restart. \($0.localizedDescription)" }


			let earthquakes = networkResponse
				.capture(case: Result.success)
				.map { Earthquake.earthquakes(from: $0) }

			let earthquakeCellViewModels = earthquakes
				.map { $0.map { EarthquakeCellViewModel(earthquake: $0) } }

			let endRefreshing = networkResponse
				.map { _ in }
				.throttle(.milliseconds(500))

			let errorMessage = Driver.merge(error, internalError)

			let displayEarthquake = inputs.selectEarthquake
				.withLatestFrom(earthquakes) { $1[$0.row] }

			return (
				UIOutputs(earthquakeCellViewModels: earthquakeCellViewModels, endRefreshing: endRefreshing, errorMessage: errorMessage),
				displayEarthquake
			)
		}
	}
}

typealias DataTask = (URLRequest) -> Driver<URLResponse>
