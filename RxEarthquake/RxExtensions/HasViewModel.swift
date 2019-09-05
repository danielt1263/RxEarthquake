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
		return Observable.create { [weak self] observer in
			let disposable = CompositeDisposable()
			self?.viewModelFactory = { inputs in
				let vm = outputFactory(inputs)
				_ = disposable.insert(vm.1.bind(to: observer))
				return vm.0
			}

			return disposable
		}
	}
}
