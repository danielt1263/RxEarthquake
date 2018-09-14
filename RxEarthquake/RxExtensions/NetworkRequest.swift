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

func data(request: URLRequest) -> Observable<NetworkResponse> {
	return Observable.create { observer in
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let data = data, let response = response as? HTTPURLResponse {
				observer.onNext(.success(request, data, response))
				observer.onCompleted()
			}
			else {
				observer.onNext(.failure(request, error ?? RxError.unknown))
				observer.onCompleted()
			}
		}
		task.resume()
		return Disposables.create { task.cancel() }
		}
		.trackActivity(networkActivity)
}

enum NetworkResponse {
	case success(URLRequest, Data, HTTPURLResponse)
	case failure(URLRequest, Error)

	var request: URLRequest {
		switch self {
		case let .success(request, _, _), let .failure(request, _):
			return request
		}
	}

	var successResponse: (Data, HTTPURLResponse)? {
		if case let .success(_, data, response) = self {
			return (data, response)
		}
		return nil
	}

	var failureResponse: Error? {
		if case let .failure(_, error) = self {
			return error
		}
		return nil
	}
}

private
let networkActivity = ActivityIndicator()
