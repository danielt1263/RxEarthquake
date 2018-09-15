//
//  AsDriverLogError.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/15/18.
//  Copyright © 2018 Daniel Tartaglia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableConvertibleType {

	public func asDriverLogError() -> SharedSequence<DriverSharingStrategy, Self.E> {
		return asDriver(onErrorRecover: { print("Error:", $0); return .empty() })
	}
}
