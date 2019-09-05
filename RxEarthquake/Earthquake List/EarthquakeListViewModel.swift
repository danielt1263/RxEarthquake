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

enum EarthquakeList {
	struct UIInputs {
		let selectEarthquake: Observable<IndexPath>
		let refreshTrigger: Observable<Void>
		let viewAppearTrigger: Observable<Void>
	}

	struct UIOutputs {
		let earthquakeCellViewModels: Driver<[EarthquakeCellViewModel]>
		let endRefreshing: Driver<Void>
		let errorMessage: Driver<String>
	}

	static func viewModel(dataTask: @escaping DataTask) -> (UIInputs) -> (UIOutputs, Observable<Earthquake>) {
		return { inputs in
			let networkResponse = Observable.merge(inputs.refreshTrigger, inputs.viewAppearTrigger)
				.map { URLRequest.earthquakeSummary }
				.flatMapLatest { dataTask($0) }
				.share()

			let earthquakeSummaryServerResponse = networkResponse
				.compactMap { $0.successResponse }

			let error = networkResponse
				.compactMap { $0.failureResponse }
				.map { $0.localizedDescription }

			let failure = earthquakeSummaryServerResponse
				.filter { $0.1.statusCode / 100 != 2 }
				.map { "There was a server error (\($0))" }

			let earthquakes = earthquakeSummaryServerResponse
				.filter { $0.1.statusCode / 100 == 2 }
				.map { Earthquake.earthquakes(from: $0.0) }

			let earthquakeCellViewModels = earthquakes
				.map { $0.map { EarthquakeCellViewModel(earthquake: $0) } }
				.asDriverLogError()

			let endRefreshing = networkResponse
				.map { _ in }
				.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
				.asDriverLogError()

			let errorMessage = Observable.merge(error, failure)
				.asDriverLogError()

			let displayEarthquake = inputs.selectEarthquake
				.withLatestFrom(earthquakes) { $1[$0.row] }

			return (
				UIOutputs(earthquakeCellViewModels: earthquakeCellViewModels, endRefreshing: endRefreshing, errorMessage: errorMessage),
				displayEarthquake
			)
		}
	}

}

typealias DataTask = (URLRequest) -> Single<URLResponse>
