# Meteor-Promissum
_A Promise wrapper for Meteor iOS_

=======

This lib combines the awesome [Meteor iOS](https://github.com/martijnwalraven/meteor-ios) lib by [Martijn Walraven](https://github.com/martijnwalraven) and [Tom Lokhorst](https://github.com/tomlokhorst)'s Promise implementation [Promissum](https://github.com/tomlokhorst/Promissum). It features full promise functionality and a way to give Meteor iOS something more that just an `AnyObject?` and `NSError?`.

=======

# Example

Incorporating promises in meteor will become very simple:

```swift

import Promissum
import Meteor
import MeteorPromissum

let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "wss://meteor-ios-todos.meteor.com/websocket"))

Meteor.connect()

Meteor.callMethodWithNamePromise("doSomething", parameters: nil)
	.then { (result: String) in
		print("YAY! It worked!")
		print("Result: \(result)")
	}
	.trap { error in
		print("Oops, got an error \(error)")
	}

```

In this example I call a Meteor method `doSomething`, and expect the result type to become `String`. Right now all Javascript primitives are supported: `Void`, `String`, `Bool` and `NSNumber` (for `Float`, `Int` and others). I plan on fixing supporting `Float`'s and `Int`'s directly instead of `NSNumber`.

If you plan on more than one result type, allthough I would highly discurage, you always can use `AnyObject` and cast it yourself.

When the return type doesn't match the requested one, the method will throw an `MeteorError.UnexpectedResultType`. It'll also do some magic in handling some basic Meteor errors like `EndpointNotFound`

If you plan on returning null in Javascript, you can also use the Optional version of `callMethodWithNamePromiseOptional`. This'll wrap `T` in `Optional<T>`, so the result would become i.e. `String?` or `NSNumber?`.

```swift
Meteor.callMethodWithNamePromiseOptional("doSomething", parameters: nil)
	.then { (result: String?) in
		if let result = result {
			print("Got some result: \(result)")
		} else {
			print("Got null result, but method succeeded.")
		}
	}
	.trap { error in
		print("Oops, got an error \(error)")
	}

```

## Subscriptions

This structure also works for creating subscriptions:

```swift

Meteor.addSubscriptionPromise("someSubscription", parameters: ["Foo", "Bar"])
	.then { subscription in
		print("YAY! Subscribed")
	}
	.trap {
		print("Meh. Got error:( \($0)")
	}

```

## Other features

Of course promises provide a whole lot of other functions that could aggegrate you calls. For instance: wait for multiple calls:

```swift

// Wait for both a call and a subscription
whenBoth(Meteor.callMethodWithNamePromise("doSomething", parameters: nil), Meteor.addSubscriptionPromise("someSubscription", parameters: ["Foo", "Bar"]))
	.then { (success: Bool, subscription: METSubscription) in
		print("YAY! Both succeeded!")
	}
	.trap {
		print("Meh, these error occurred: \($0)")
	}

```

or `map`/`flatMap` your results:

```swift
let subscriptionAfterCheck = Meteor.callMethodWithNamePromise("doSomeChecking", parameters: nil)
	.flatMap { (success: Bool) in
		if success {
			return Meteor.addSubscriptionPromise("someSubscription", parameters: ["Foo", "Bar"])
		}
		return Promise(error: SomeNSError)
	}
```

# Installation

Figuring you already have Meteor iOS installed, this lib depends on `Promissum`. Since I only support Cocoapods for now, I highly recommend importing both via you `Podfile` like this:


```ruby
pod 'Meteor'
pod 'Promissum'

pod 'MeteorPromises', :git => 'https://github.com/Q42/Meteor-Promissum.git', :tag => '0.0.4'
```

I know, I should get my spec up at Cocoapods.

It actually only is a category file that contains some extensions. You could also just import [Meteor+Promises.swift](https://github.com/Q42/Meteor-Promissum/blob/master/Meteor%2BPromissum/Meteor%2BPromises.swift) in you project.