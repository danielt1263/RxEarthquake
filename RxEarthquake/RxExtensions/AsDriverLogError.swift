//
//  AsDriverLogError.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/15/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableConvertibleType {

	public func asDriverLogError(_ file: StaticString = #file, _ line: UInt = #line) -> SharedSequence<DriverSharingStrategy, E> {
		return asDriver(onErrorRecover: { print("Error:", $0, " in file:", file, " atLine:", line); return .empty() })
	}
}
