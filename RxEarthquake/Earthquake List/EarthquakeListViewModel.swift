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
import RxSwiftExt

class EarthquakeListViewModel {
	struct UIInputs {
		let selectEarthquake: Observable<Earthquake>
		let refreshTrigger: Observable<Void>
		let viewAppearTrigger: Observable<Void>
	}

	let earthquakes: Driver<[Earthquake]>
	let endRefreshing: Driver<Void>
	let errorMessage: Driver<String>

	let networkRequest: Driver<URLRequest>
    let displayEarthquake: Driver<Earthquake>

	init(_ inputs: UIInputs, http: Observable<NetworkResponse>) {
		
		let earthquakeSummary = http
			.filter { $0.request == URLRequest.earthquakeSummary }

		let earthquakeSummaryServerResponse = earthquakeSummary
			.map { $0.successResponse }
			.unwrap()

		let error = earthquakeSummary
			.map { $0.failureResponse }
			.unwrap()
			.map { $0.localizedDescription }
			.asDriver(onErrorJustReturn: "")

		let failure = earthquakeSummaryServerResponse
			.filter { $0.1.statusCode / 100 != 2 }
			.map { "There was a server error (\($0))" }
			.asDriver(onErrorJustReturn: "")

        displayEarthquake = inputs.selectEarthquake
            .asDriver(onErrorRecover: { _ in fatalError() })
        
		networkRequest = Observable.merge(inputs.refreshTrigger, inputs.viewAppearTrigger)
			.map { URLRequest.earthquakeSummary }
			.asDriver(onErrorRecover: { _ in fatalError() })

		earthquakes = earthquakeSummaryServerResponse
			.filter { $0.1.statusCode / 100 == 2 }
			.map { Earthquake.earthquakes(from: $0.0) }
			.asDriver(onErrorJustReturn: [])

		endRefreshing = earthquakeSummary
			.map { _ in }
			.throttle(0.5, scheduler: MainScheduler.instance)
			.asDriver(onErrorJustReturn: ())

		errorMessage = Driver.merge(error, failure)
	}
}
