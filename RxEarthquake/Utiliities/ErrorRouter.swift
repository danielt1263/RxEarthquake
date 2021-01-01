//
// Created by Daniel Tartgaglia on 12/19/2020.
// Copyright (c) 2020 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
	/// Absorbs errors and routes them to the error router instead. If the source emits an error, this operator will emit a completed event and the error router will emit the error as a next event.
	/// - Parameter errorRouter: The error router that will accept the error.
	/// - Returns: The source observable's events with an error event converted to a completed event.
	func rerouteError(_ errorRouter: AnyObserver<Error>) -> Observable<Element> {
		self.catch { error in
			errorRouter.onNext(error)
			return Observable.empty()
		}
	}
}
