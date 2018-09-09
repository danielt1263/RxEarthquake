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
				observer.onNext(.success(data, response))
				observer.onCompleted()
			}
			else {
				observer.onNext(.failure(error ?? RxError.unknown))
				observer.onCompleted()
			}
		}
		task.resume()
		return Disposables.create { task.cancel() }
	}
	.trackActivity(networkActivity)
}

enum NetworkResponse {
	case success(Data, HTTPURLResponse)
	case failure(Error)

	var successResponse: (Data, HTTPURLResponse)? {
		if case let .success(data, response) = self {
			return (data, response)
		}
		return nil
	}

	var failureResponse: Error? {
		if case let .failure(error) = self {
			return error
		}
		return nil
	}
}

private
let networkActivity = ActivityIndicator()
