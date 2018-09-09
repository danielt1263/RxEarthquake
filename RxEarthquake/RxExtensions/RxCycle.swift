//
//  RxCycle.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/8/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift

class RxCycle<Input, Output>: ObserverType {

	typealias E = Input

	init(_ fun: @escaping (Input) -> Single<Output>) {
		output = input
			.flatMap(fun)
			.share()
	}

	init(_ fun: @escaping (Input) -> Observable<Output>) {
		output = input
			.flatMap(fun)
			.share()
	}

	func on(_ event: Event<E>) {
		input.on(event)
	}

	let output: Observable<Output>

	private let input = PublishSubject<Input>()

}
