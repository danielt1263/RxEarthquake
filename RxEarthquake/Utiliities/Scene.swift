//
//  Scene.swift
//
//  Created by Daniel Tartaglia on 12/5/20.
//  Copyright © 2020 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift

struct Scene<Action> {
	let controller: UIViewController
	let action: Observable<Action>
}

/// shortcuts for creating scenes and view controllers.
extension NSObjectProtocol where Self: UIViewController {
	/**
	Create a scene by reconstituting an instance of this view controller from a storyboard with the same name as it.

	- Parameter connect: A function describing how the view controller should be connected and returning an Observable that emits any data the scene needs to communicate to its parent.
	- Parameter storyboardName: The name of the storyboard. If not supplied then the name of the view controller is assumed.
	- Parameter bundle: The bundle to look for the storyboard in. If not supplied then the system will look in the main bundle.
	- Returns: A Scene containing the view controller and return value of the connect function.

	Example:

	`let exampleScene = ExampleViewController.scene { $0.connect() }`
	*/
	static func scene<Action>(storyboardName: String? = nil, bundle: Bundle? = nil, _ connect: (Self) -> Observable<Action>) -> Scene<Action> {
		let storyboard = UIStoryboard(name: storyboardName ?? String(describing: self), bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! Self
		return controller.scene(connect)
	}

	/**
	Extract an instance of this view controller out of a storyboard with the same name as it and cofigure it using the supplied connect function.

	- Parameter connect: A function describing how the view controller should be connected.
	- Parameter storyboardName: The name of the storyboard. If not supplied then the name of the view controller is assumed.
	- Parameter bundle: The bundle to look for the storyboard in. If not supplied then the system will look in the main bundle.
	- Returns: A configured view controller.

	Example:

	`let exampleViewController = ExampleViewController.create { $0.connect() }`
	*/
	static func create(storyboardName: String? = nil, bundle: Bundle? = nil, _ connect: (Self) -> Void) -> UIViewController {
		let storyboard = UIStoryboard(name: storyboardName ?? String(describing: self), bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! Self
		return controller.configure(connect)
	}

	/**
	Create a scene from an already existing view controller.

	- Parameter connect: A function describing how the view controller should be connected and returning an Observable that emits any data the scene needs to communicate to its parent.
	- Returns: A Scene containing the view controller and return value of the connect function.

	Example:

	`let exampleScene = ExampleViewController().scene { $0.connect() }`
	*/
	func scene<Action>(_ connect: (Self) -> Observable<Action>) -> Scene<Action> {
		loadViewIfNeeded()
		return Scene(controller: self, action: connect(self))
	}

	/**
	Configure an existing view controller using the supplied connect function.

	- Parameter connect: A function describing how the view controller should be connected.
	- Returns: A configured view controller.

	Example:

	`let exampleViewController = ExampleViewController().create { $0.connect() }`
	*/
	func configure(_ connect: (Self) -> Void) -> UIViewController {
		loadViewIfNeeded()
		connect(self)
		return self
	}
}
