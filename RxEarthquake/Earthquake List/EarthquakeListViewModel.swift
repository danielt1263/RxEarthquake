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
		let networkTriggers = Observable.merge(inputs.refreshTrigger, inputs.viewAppearTrigger)

        displayEarthquake = inputs.selectEarthquake
            .asDriver(onErrorRecover: { _ in fatalError() })
        
		networkRequest = networkTriggers
			.map { URLRequest.earthquakeSummary }
			.asDriver(onErrorRecover: { _ in fatalError() })

		earthquakes = http
			.map { $0.successResponse }
			.unwrap()
			.filter { $0.1.statusCode / 100 == 2 && $0.1.url! == URLRequest.earthquakeSummary.url! }
			.map { Earthquake.earthquakes(from: $0.0) }
			.asDriver(onErrorJustReturn: [])

		endRefreshing = http
			.map { _ in }
			.throttle(0.5, scheduler: MainScheduler.instance)
			.asDriver(onErrorJustReturn: ())

		let failure = http
			.map { $0.successResponse }
			.unwrap()
			.filter { $0.1.statusCode / 100 != 2 && $0.1.url! == URLRequest.earthquakeSummary.url! }
			.map { "There was a server error (\($0))" }
			.asDriver(onErrorJustReturn: "")

		let error = http
			.map { $0.failureResponse }
			.unwrap()
			.map { $0.localizedDescription }
			.asDriver(onErrorJustReturn: "")

		errorMessage = Driver.merge(failure, error)
	}
}
