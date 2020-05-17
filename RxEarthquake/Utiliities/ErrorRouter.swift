//
// Created by sergdort on 03/02/2017.
// Copyright (c) 2017 sergdort. MIT License.
//
// sourced from: https://github.com/sergdort/CleanArchitectureRxSwift/blob/master/CleanArchitectureRxSwift/Utility/ErrorTracker.swift
//

import Foundation
import RxSwift
import RxCocoa

/// Reroutes errors out of the strream they were emitted from and into itself as a next event.
final class ErrorRouter: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<Error>()

    func rerouteError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
		return source.asObservable()
			.catchError { [_subject] error in
				_subject.onNext(error)
				return Observable.empty()
			}
    }

    func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
		return _subject.asObservable().asDriver(onErrorRecover: { _ in Driver.empty() })
    }

    func asObservable() -> Observable<Error> {
        return _subject.asObservable()
    }

    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
	/// Absorbes errors and routes them to the error router instead. If the source emits an error, this operator will emit a completed event and the error router will emit the error as a next event.
	/// - Parameter errorRouter: The error router that will accept the error.
	/// - Returns: The source observable's events with an error event converted to a completed event.
    func rerouteError(_ errorRouter: ErrorRouter) -> Observable<Element> {
        return errorRouter.rerouteError(from: self)
    }
}
