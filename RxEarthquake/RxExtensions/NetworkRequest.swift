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
import EnumKit

let isNetworkActive: Driver<Bool> = {
	return networkActivity.asDriver()
}()

typealias URLResponse = Result<Data, Error>

func dataTask(with request: URLRequest) -> Driver<URLResponse> {
	return URLSession.shared.rx.data(request: request)
		.trackActivity(networkActivity)
		.asDriverResult()
}

extension Result: CaseAccessible { }

private
let networkActivity = ActivityIndicator()
