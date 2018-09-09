# RxEarthquake

This repository exists to demonstrate my technique and philosophy when building a project using the ReactiveX RxSwift library. Key ideas include:

1. View controllers are isolated and know nothing of their parent or sibling view controllers. This promotes reuse and easy modification.
2. The code base is written with an output centric approach to help with debugging the system.
3. The code is written in a highly declarative style with a strong separation between logic and effect to help in understanding.

I find these values so useful that I aim to provide them even when not using a FRP library like RxSwift, but using such a library makes writing such code easier.

## Isolate View Controllers

In a program written in the typical MVC style, every view controller knows how it was displayed, whether it has been presented or pushed onto a navigation stack, and knows about the next view controller(s) that will be shown to the user. In some code bases, it will even create and then tell it's parent to display its siblings. Such code distributes the display order into every part of the system. This makes it hard to reuse view controllers in different contexts and re-ordering the presentation flow of a series of view controllers requires carefully adjusting multiple classes.

In this sample program, the `Coordinator` is in charge of the navigation flow. It determines when and how view controllers are displayed and removed. I expect to need one  Coordinator class for every split view, navigation, or other container controller in the system and that coordinator is in charge of displaying the contents of that container controller. In this particular case, despite there being two navigation controllers, the split view controller is in charge of what they display and so I only ended up with one coordinator.

