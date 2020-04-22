//
//  AsDriverResult.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/15/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {

	public func asDriverResult() -> Driver<Result<Element, Error>> {
		map { Result.success($0) }
			.asDriver(onErrorRecover: { Driver.just(.failure($0)) })
	}
}
