//
//  HasViewModel.swift
//  RxMyCoordinator
//
//  Created by Daniel Tartaglia on 2/22/19.
//

import Foundation
import RxSwift
import RxCocoa

protocol HasViewModel: class {
	associatedtype Inputs
	associatedtype Outputs
	var viewModelFactory: (Inputs) -> Outputs { get set }
}

extension HasViewModel {
	func installOutputViewModel<T>(outputFactory: @escaping (Inputs) -> (Outputs, Driver<T>)) -> Driver<T> {
		let result = PublishSubject<T>()
		viewModelFactory = { inputs in
			let vm = outputFactory(inputs)
			_ = vm.1.drive(result)
			return vm.0
		}
		return result.asDriver(onErrorRecover: { fatalError("\($0.localizedDescription)") })
	}
}
