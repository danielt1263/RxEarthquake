# RxEarthquake

This repository exists to demonstrate my technique and philosophy when building a project using the ReactiveX RxSwift library. Key ideas include:

1. View controllers are isolated and know nothing of their parent or sibling view controllers. This promotes reuse and easy modification.
2. The code base is written with an output centric approach to help with debugging the system.
3. The code is written in a highly declarative style with a strong separation between logic and effects to help in understanding.

I find these values so useful that I aim to provide them even when not using a FRP library like RxSwift, but using such a library makes writing such code easier.

## Isolate View Controllers

In a program written in the typical MVC style, every view controller knows how it was displayed, whether it has been presented or pushed onto a navigation stack, and knows about the next view controller(s) that will be shown to the user. In some code bases, it will even create and then tell it's parent to display its siblings. Such code distributes the display order into every part of the system. This makes it hard to reuse view controllers in different contexts and re-ordering the presentation flow of a series of view controllers requires carefully adjusting multiple classes.

In this sample program, the `Coordinator` is in charge of the navigation flow. It determines when and how view controllers are displayed and removed. I expect to need one  Coordinator class for every split view, navigation, or other container controller in the system and that coordinator is in charge of displaying the contents of that container controller. In this particular case, despite there being two navigation controllers, the split view controller is in charge of what they display so I ended up with only one coordinator. If view controllers were getting pushed onto either navigation controller, then another coordinator would be required.

## Output Centric Approach

When first learning to program, and in most sample code, we learn an input centric approach. This means that when examining the code you can readly find a function that defines exactly what happens when, for e.g., a button is tapped or a piece of text is entered. However, when it comes time to figure out what a particular output should read or action should happen we find that there are several functions that all write to that output or perform that action. This makes it hard to track what the output should be at any one time.

In my code, I strive for a more output centric approach. This means there is only one place where a particuler side effect happens and all the reasons that could cause that side effect are gathered together with it. This is where Reactive Extensions help out tremendiously. Output centric code can be done without Rx, but it's much more convoluted. 

## Declarative Style

Most example programs are written in an imperative style, where any particular line of code represents a step in a process and doesn't tell you anything about the process as a whole. Writing with reactive extensions gives me the chance to write code in a more declarative style where each line of code doesn't just represent a step in a process, but rather it represents a fundimental truth, something that will always be the case. I wrote a short article about this subject. [Imperative vs Declarative Programming](https://medium.com/@danielt1263/imperative-vs-declarative-programming-a74f6cceff0e)

---

If you have any questions about how the code is written, or about the code itself, I would love to read them. Post an issue with your question and I'll do my best to respond.
