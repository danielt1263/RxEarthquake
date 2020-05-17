# RxEarthquake

This repository exists to demonstrate my technique and philosophy when building a project using the ReactiveX RxSwift library. Key ideas include:

1. View controllers are isolated and know nothing of their parent or sibling view controllers. This promotes reuse and easy modification.
2. The code base is written using a Cause-Logic-Effect Architecture.
3. The resulting code is highly declarative style with a strong separation between logic and effects which help in understanding.

I find these values so useful that I aim to provide them even when not using a FRP library like RxSwift, but using such a library makes writing such code easier.

## Isolate View Controllers

In a program written in the typical MVC style, every view controller knows how it was displayed, whether it has been presented or pushed onto a navigation stack, and knows about the next view controller(s) that will be shown to the user. In some code bases, it will even create and then tell it's parent to display its siblings. Such code distributes the display order into every part of the system. This makes it hard to reuse view controllers in different contexts and re-ordering the presentation flow of a series of view controllers requires carefully adjusting multiple classes.

In this sample program, the `Coordinator` is in charge of the navigation flow. It determines when and how view controllers are displayed and removed. I expect to need one  Coordinator class for every split view, navigation, or other container controller in the system and that coordinator is in charge of displaying the contents of that container controller. In this particular case, despite there being two navigation controllers, the split view controller is in charge of what they display so I ended up with only one coordinator. If view controllers were getting pushed onto either navigation controller, then another coordinator would be required.

## Cause-Logic-Effect Architecture

An effect is any side effect, a network request, changing the state of a view, saving to a DB, notifying an external system of some event, etc. Once you have an effect in mind, then you outline the causes (events) that cause that effect to happen, the result of a network request, a user action, a notification from some external system, etc. There are often several causes that all contribute to a single effect... Then you create a function that maps the cause(s) to the effect you are trying to achieve. Such functions can be found in the files titled "...Logic.swift"

Of course an effect often contributes a cause to some other effect. You will see such code with the network request and when a user chooses an item from the table view of one view controller which influnces the output of a different view controller.

The system also allows us to bundle a bunch of cause-logic-effect chains into a single effect. Examples include the functions that create view controllers. These are cause/effect bundles.

The benefits of the architecture is that logic is isolated and easy to test without the need for test doubles. No mocks, fakes or stubs. No need for dependency injection. New features can easily be added by simply outlining the effects of the new feature, or changes to current effects. Bugs are easy to isolate because all the causes for a particular effect, as well as the logic for that effect, are fully self-contained in a single function.

## Declarative Style

Most example programs are written in an imperative style, where any particular line of code represents a step in a process and doesn't tell you anything about the process as a whole. Writing with reactive extensions gives me the chance to write code in a more declarative style where each function doesn't just represent a step in a process, but rather it represents a fundimental truth, something that will always be the case. I wrote a short article about this subject. [Imperative vs Declarative Programming](https://medium.com/@danielt1263/imperative-vs-declarative-programming-a74f6cceff0e)

---

If you have any questions about how the code is written, or about the code itself, I would love to read them. Post an issue with your question and I'll do my best to respond. I am also active in the RxSwift slack channel as well as on Stack Overflow.
