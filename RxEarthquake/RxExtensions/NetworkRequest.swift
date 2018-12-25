//
//  NetworkRequest.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/8/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import RxCocoa

let isNetworkActive: Driver<Bool> = {
	return networkActivity.asDriver()
}()

typealias URLResponse = Result<(data: Data, response: HTTPURLResponse)>

func dataTask(with request: URLRequest) -> Single<URLResponse> {
	return Single.create { observer in
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let data = data, let response = response as? HTTPURLResponse {
				observer(.success(URLResponse(success: (data, response))))
			}
			else {
				observer(.success(URLResponse(failure: error ?? RxError.unknown)))
			}
		}
		task.resume()
		return Disposables.create { task.cancel() }
	}
	.trackActivity(networkActivity)
	.asSingle()
}

struct Result<T> {
	let successResponse: T?
	let failureResponse: Error?

	init(success: T) {
		successResponse = success
		failureResponse = nil
	}

	init(failure: Error) {
		successResponse = nil
		failureResponse = failure
	}
}

private
let networkActivity = ActivityIndicator()
