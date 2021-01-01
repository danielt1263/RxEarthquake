//
//  Stage.swift
//
//  Created by Daniel Tartaglia on 8/24/20.
//  Copyright © 2020 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift

/**
Presents a scene onto the top view controller of the presentation stack. The scene will be dismissed when either the action observable completes/errors or is disposed.
- Parameters:
- animated: Pass `true` to animate the presentation; otherwise, pass `false`.
- sourceView: If the scene will be presented in a popover controller, this is the view that will serve as the focus.
- scene: A factory function for creating the Scene.
- Returns: The Scene's output action `Observable`.
*/
func presentScene<Action>(animated: Bool, overSourceView sourceView: UIView? = nil, scene: @escaping () -> Scene<Action>) -> Observable<Action> {
	Observable.using({ ScenePresentationHandler(scene: scene(), sourceView: sourceView, animated: animated) }, observableFactory: { $0.action })
}

/**
Presents a scene onto the top view controller of the presentation stack. Can be used in a bind/subscribe/do onNext closure. The scene will dismiss when the action observable completes or errors.
- Parameters:
- animated: Pass `true` to animate the presentation; otherwise, pass `false`.
- sourceView: If the scene will be presented in a popover controller, this is the view that will serve as the focus.
- scene: A factory function for creating the Scene.
*/
func finalPresentScene<Action>(animated: Bool, overSourceView sourceView: UIView? = nil, scene: @escaping () -> Scene<Action>) {
	_ = presentScene(animated: animated, overSourceView: sourceView, scene: scene)
		.subscribe()
}

/**
Push a scene onto a navigation constroller's stack. The scene will be popped when either the action observable completes/errors or is disposed.
- Parameter navigation: The navigation controller that scenes will be pushed onto.
- Returns: A function that will push the given scene with the given animation state and returns the scenes output action.
*/
func pushScene<Action>(on navigation: UINavigationController) -> (_ animated: Bool, _ scene: @escaping () -> Scene<Action>) -> Observable<Action> {
	weak var nav = navigation
	return { animated, scene in
		nav!.pushScene(animated: animated, scene: scene)
	}
}

/**
Pushes a scene onto a navigation controller's stack. Can be used in a bind/subscribe/do onNext closure. The scene will be popped when the action observable completes or errors.
- Parameter navigation: The navigation controller that scenes will be pushed onto.
- Returns: A function that will push the given scene with the given animation state and returns the scenes output action.
*/
func finalPushScene<Action>(on navigation: UINavigationController) -> (_ animated: Bool, _ scene: @escaping () -> Scene<Action>) -> Void {
	weak var nav = navigation
	return { animated, scene in
		nav!.finalPushScene(animated: animated, scene: scene)
	}
}

extension UINavigationController {
	/**
	Push a scene onto a navigation constroller's stack. The scene will be popped when either the action observable completes/errors or is disposed.
	- Parameters:
	- animated: Pass `true` to animate the presentation; otherwise, pass `false`.
	- scene: A factory function for creating the Scene.
	- Returns: The Scene's output action `Observable`.
	*/
	func pushScene<Action>(animated: Bool, scene: @escaping () -> Scene<Action>) -> Observable<Action> {
		Observable.using({ [weak self] in SceneNavigationHandler(parent: self, scene: scene(), animated: animated) }, observableFactory: { $0.action })
	}

	/**
	Pushes a scene onto a navigation controller's stack. Can be used in a bind/subscribe/do onNext closure. The scene will be popped when the action observable completes or errors.
	- Parameters:
	- animated: Pass `true` to animate the presentation; otherwise, pass `false`.
	- scene: A factory function for creating the Scene.
	*/
	func finalPushScene<Action>(animated: Bool, scene: @escaping () -> Scene<Action>) {
		_ = pushScene(animated: animated, scene: scene)
			.subscribe()
	}
}

private final class SceneNavigationHandler<Action>: Disposable {
	weak var parent: UINavigationController?
	weak var saveTop: UIViewController?
	weak var child: UIViewController?
	let action: Observable<Action>
	let isAnimated: Bool

	init(parent: UINavigationController?, scene: Scene<Action>, animated: Bool) {
		self.parent = parent
		child = scene.controller
		action = scene.action
		isAnimated = animated
		saveTop = parent?.topViewController
		parent?.pushViewController(scene.controller, animated: animated)
	}

	func dispose() {
		guard let saveTop = saveTop else { return }
		parent?.popToViewController(saveTop, animated: isAnimated)
	}
}

private let queue = DispatchQueue(label: "ScenePresentationHandler")

private final class ScenePresentationHandler<Action>: Disposable {
	weak var parent: UIViewController?
	weak var child: UIViewController?
	let action: Observable<Action>
	let isAnimated: Bool

	init(scene: Scene<Action>, sourceView: UIView?, animated: Bool) {
		child = scene.controller
		action = scene.action
		isAnimated = animated

		queue.async {
			let semaphore = DispatchSemaphore(value: 0)
			DispatchQueue.main.async {
				if let popoverPresentationController = scene.controller.popoverPresentationController, let sourceView = sourceView {
					popoverPresentationController.sourceView = sourceView
					popoverPresentationController.sourceRect = sourceView.bounds
				}

				self.parent = UIViewController.top()
				self.parent!.present(scene.controller, animated: animated, completion: {
					semaphore.signal()
				})
			}
			semaphore.wait()
		}
	}

	func dispose() {
		queue.async { [parent, child, isAnimated] in
			let semaphore = DispatchSemaphore(value: 0)
			DispatchQueue.main.async {
				if let parent = parent, let child = child, parent.presentedViewController === child {
					parent.dismiss(animated: isAnimated, completion: {
						semaphore.signal()
					})
				}
				else {
					semaphore.signal()
				}
			}
			semaphore.wait()
		}
	}
}

private extension UIViewController {
	static func top() -> UIViewController {
		guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { fatalError("No view controller present in app?") }
		var result = rootViewController
		while let vc = result.presentedViewController {
			result = vc
		}
		return result
	}
}
