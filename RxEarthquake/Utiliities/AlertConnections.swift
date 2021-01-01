//
//  AlertConnections.swift
//
//  Created by Daniel Tartaglia on 11/6/20.
//  Copyright © 2020 Daniel Tartaglia. MIT License.
//

import RxCocoa
import RxSwift
import UIKit

extension UIAlertController {
	func connectOK(buttonTitle: String = "OK") -> Observable<Void> {
		let action = PublishSubject<Void>()
		addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
			action.onSuccess(())
		}))
		return action
	}

	func connectChoice<T>(choices: [T], description: (T) -> String = { String(describing: $0) }) -> Observable<T?> {
		let action = PublishSubject<T?>()

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in action.onSuccess(nil) })

		let actions = choices.map { element in
			UIAlertAction(title: description(element), style: .default, handler: { _ in action.onSuccess(element) })
		}

		for action in actions + [cancelAction] {
			addAction(action)
		}

		return action
	}
}
