//
//  Meteor+Promises.swift
//  Meteor+Promises
//
//  Created by Tomas Harkema on 21-02-16.
//  Copyright © 2016 Q42. All rights reserved.
//

import Foundation
import Promissum
import Meteor

public enum MeteorError: ErrorType {
  case EndpointNotFound(methodName: String)
  case UnexpectedResultType(expected: String, received: String)
  case NoResponseReceived
  case IllegalArgument(String)
  case Undefined(String)
  case Unknown(NSError)

  init(_ error: NSError, endpoint: String? = nil) {

    if let meteorError = error as? MeteorError {
      self = meteorError
      return
    }

    if let reason = (error as NSError).localizedFailureReason?.lowercaseString {
      if reason.containsString("not found") {
        self = .EndpointNotFound(methodName: endpoint.map { "Method \'\($0)\' not found" } ?? reason)
        return
      }

      if reason.containsString("cannot read property") {
        self = .IllegalArgument(reason)
        return
      }

      if reason.containsString("undefined") {
        self = .Undefined(reason)
        return
      }
    }
    self = .Unknown(error as NSError)
  }
}

extension MeteorError: Equatable {}

// error description

public func ==(lhs: MeteorError, rhs: MeteorError) -> Bool {
  switch (lhs, rhs) {
  case let (.EndpointNotFound(l), .EndpointNotFound(r)):
    return l == r

  case let (.UnexpectedResultType(l), .UnexpectedResultType(r)):
    return l == r

  case (.NoResponseReceived, .NoResponseReceived):
    return true

  case let (.Unknown(l), .Unknown(r)):
    return l == r

  default: return false
  }
}

public extension METDDPClient {

  static func methodCallToPromise<T>(methodName: String, _ promiseSource: PromiseSource<T, MeteorError>) -> METMethodCompletionHandler {
    return { (result: AnyObject?, error: NSError?) in

      if let error = error {
        promiseSource.reject(MeteorError(error, endpoint: methodName))
        return
      }

      if let result = result as? T {
        promiseSource.resolve(result)
      } else {
        if T.self == Void.self {
          promiseSource.resolve(Void() as! T)
        } else {
          // make errors look better
          if let result = result {
            promiseSource.reject(MeteorError.UnexpectedResultType(expected: "\(T.self)", received: "\(result.dynamicType)(\(result.self))"))
          } else {
            promiseSource.reject(MeteorError.UnexpectedResultType(expected: "\(T.self)", received: "\(result.dynamicType)(\(result.self))"
              .stringByReplacingOccurrencesOfString("Optional<AnyObject>(nil)", withString: "nil")))
          }
        }
      }
    }
  }

  static func methodCallToPromiseOptional<T>(methodName: String,  _ promiseSource: PromiseSource<Optional<T>, MeteorError>) -> METMethodCompletionHandler {
    return { (result: AnyObject?, error: NSError?) in

      if let error = error {
        promiseSource.reject(MeteorError(error, endpoint: methodName))
        return
      }
      
      if let result = result as? Optional<T> {
        promiseSource.resolve(result)
      } else {
        // make errors look better
        if let result = result {
          promiseSource.reject(MeteorError.UnexpectedResultType(expected: "\(T.self)", received: "\(result.dynamicType)(\(result.self))"))
        } else {
          promiseSource.reject(MeteorError.UnexpectedResultType(expected: "\(T.self)", received: "\(result.dynamicType)(\(result.self))"))
        }
      }
    }
  }

  public func callMethodWithNamePromiseOptional<T>(methodName: String, parameters: [AnyObject]?) -> Promise<Optional<T>, MeteorError> {

    let promiseSource = PromiseSource<Optional<T>, MeteorError>()

    callMethodWithName(methodName, parameters: parameters, completionHandler: METDDPClient.methodCallToPromiseOptional(methodName, promiseSource))

    return promiseSource.promise
  }

  public func callMethodWithNamePromise<T>(methodName: String, parameters: [AnyObject]?) -> Promise<T, MeteorError> {

    let promiseSource = PromiseSource<T, MeteorError>()

    callMethodWithName(methodName, parameters: parameters, completionHandler: METDDPClient.methodCallToPromise(methodName, promiseSource))

    return promiseSource.promise
  }

  public func addSubscriptionPromise(name: String, parameters: [AnyObject]?) -> Promise<METSubscription, MeteorError> {
    let promiseSource = PromiseSource<Void, ErrorType>()

    let subscription = addSubscriptionWithName(name, parameters: parameters) { error in
      if let error = error {
        promiseSource.reject(error)
      } else {
        promiseSource.resolve()
      }
    }

    return promiseSource.promise.mapMeteorError().map {
      subscription
    }
  }
}

extension Promise {
  public func mapMeteorError() -> Promise<Value, MeteorError> {
    return self.mapError { error in
      if let error = error as? NSError {
        return MeteorError(error)
      }
      return MeteorError.Unknown(NSError(domain: "Meteor+Promise", code: 500, userInfo: nil))
    }
  }
}

