//
//  DriverUnwrap.swift
//  RxEarthquake
//
//  Created by Daniel Tartaglia on 9/8/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {

	/**
	Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.

	- returns: An observable sequence of non-optional elements
	*/

	public func unwrap<T>() -> Driver<T> where E == T? {
		return self.filter { $0 != nil }.map { $0! }
	}
}
