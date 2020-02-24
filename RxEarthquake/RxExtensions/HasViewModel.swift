//
//  HasViewModel.swift
//  RxMyCoordinator
//
//  Created by Daniel Tartaglia on 2/22/19.
//

import Foundation
import RxSwift

protocol HasViewModel: class {
	associatedtype Inputs
	associatedtype Outputs
	var viewModelFactory: (Inputs) -> Outputs { get set }
}

extension HasViewModel {
	func installOutputViewModel<T>(outputFactory: @escaping (Inputs) -> (Outputs, Observable<T>)) -> Observable<T> {
		let result = PublishSubject<T>()
		viewModelFactory = { inputs in
			let vm = outputFactory(inputs)
			_ = vm.1.bind(to: result)
			return vm.0
		}
		return result
	}
}
