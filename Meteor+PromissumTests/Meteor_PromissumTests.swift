//
//  Meteor_PromissumTests.swift
//  Meteor+PromissumTests
//
//  Created by Tomas Harkema on 18-04-16.
//  Copyright © 2016 harkema.io. All rights reserved.
//

import XCTest
import Promissum
import Meteor
@testable import MeteorPromissum

class Meteor_PromissumTests: XCTestCase {
    
  func testClosureShouldHandleResultString() {
    let expectation = expectationWithDescription("Testing if closure handles results")
    let promiseSource = PromiseSource<String, MeteorError>()

    METDDPClient.methodCallToPromise(String.self, "test", promiseSource)("hallo", nil)

    promiseSource.promise
      .then { res in
        XCTAssertEqual(res, "hallo")
      }
      .trap { error in XCTFail("should not trap: \(error)") }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleResultInt() {
    let expectation = expectationWithDescription("Testing if closure handles results")
    let promiseSource = PromiseSource<NSNumber, MeteorError>()

    METDDPClient.methodCallToPromise(NSNumber.self, "test", promiseSource)(NSNumber(int: 1), nil)

    promiseSource.promise
      .then { res in
        XCTAssertEqual(res, 1)
      }
      .trap { error in XCTFail("should not trap: \(error)") }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleErrors() {
    let expectation = expectationWithDescription("Testing if closure handles errors")
    let promiseSource = PromiseSource<NSNumber, MeteorError>()

    let error = NSError(domain: "Bezorger", code: 0, userInfo: [
      NSLocalizedFailureReasonErrorKey: "Method not found"
      ])

    METDDPClient.methodCallToPromise(NSNumber.self, "test", promiseSource)(nil, error)

    promiseSource.promise
      .then { res in XCTFail("should not resolve: \(res)") }
      .trap { error in
        XCTAssertEqual(error, MeteorError.EndpointNotFound(methodName: "Method \'test\' not found"))
      }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleErrorsOptional() {
    let expectation = expectationWithDescription("Testing if closure handles errors")
    let promiseSource = PromiseSource<Optional<NSNumber>, MeteorError>()

    let error = NSError(domain: "Bezorger", code: 0, userInfo: [
      NSLocalizedFailureReasonErrorKey: "Method not found"
      ])

    METDDPClient.methodCallToPromiseOptional(NSNumber.self, "test", promiseSource)(nil, error)

    promiseSource.promise
      .then { res in XCTFail("should not resolve: \(res)") }
      .trap { error in
        XCTAssertEqual(error, MeteorError.EndpointNotFound(methodName: "Method \'test\' not found"))
      }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleOptionalNoResult() {
    let expectation = expectationWithDescription("Testing if closure handles no result")
    let promiseSource = PromiseSource<Optional<String>, MeteorError>()

    METDDPClient.methodCallToPromiseOptional(String.self, "test", promiseSource)(nil, nil)

    promiseSource.promise
      .then { res in
        XCTAssertEqual(res, nil)
      }
      .trap { error in XCTFail("should not trap: \(error)") }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleOptionalResult() {
    let expectation = expectationWithDescription("Testing if closure handles no result")
    let promiseSource = PromiseSource<Optional<String>, MeteorError>()

    METDDPClient.methodCallToPromiseOptional(String.self, "test", promiseSource)("Result", nil)

    promiseSource.promise
      .then { res in
        XCTAssertEqual(res, "Result")
      }
      .trap { error in XCTFail("should not trap: \(error)") }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleOptionalResultWrongType() {
    let expectation = expectationWithDescription("Testing if closure handles no result")
    let promiseSource = PromiseSource<Optional<NSNumber>, MeteorError>()

    METDDPClient.methodCallToPromiseOptional(NSNumber.self, "test", promiseSource)("Result", nil)

    promiseSource.promise
      .then { res in XCTFail("should not resolve: \(res)") }
      .trap { error in XCTAssertEqual(error, MeteorError.UnexpectedResultType(expected: "NSNumber", received: "_NSContiguousString(Result)")) }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldHandleNoResult() {
    let expectation = expectationWithDescription("Testing if closure handles no result")
    let promiseSource = PromiseSource<Void, MeteorError>()

    METDDPClient.methodCallToPromise(Void.self, "test", promiseSource)(nil, nil)

    promiseSource.promise
      .then { XCTAssertTrue(true) }
      .trap { error in XCTFail("should not trap: \(error)") }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldErrorOtherResultType() {
    let expectation = expectationWithDescription("Testing if closure handles no result")
    let promiseSource = PromiseSource<NSNumber, MeteorError>()

    METDDPClient.methodCallToPromise(NSNumber.self, "test", promiseSource)("Hallo", nil)

    promiseSource.promise
      .then { res in XCTFail("should not resolve: \(res)") }
      .trap { error in XCTAssertEqual(error, MeteorError.UnexpectedResultType(expected: "NSNumber", received: "_NSContiguousString(Hallo)")) }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }

  func testClosureShouldErrorOnNilResult() {
    let expectation = expectationWithDescription("Testing if closure handles no result")
    let promiseSource = PromiseSource<NSNumber, MeteorError>()

    METDDPClient.methodCallToPromise(NSNumber.self, "test", promiseSource)(nil, nil)

    promiseSource.promise
      .then { res in XCTFail("should not resolve: \(res)") }
      .trap { error in XCTAssertEqual(error, MeteorError.UnexpectedResultType(expected: "NSNumber", received: "nil")) }
      .finally(expectation.fulfill)

    waitForExpectationsWithTimeout(30) { error in
      guard let error = error else {
        return
      }
      XCTFail("Expectation failed with error: \(error)")
    }
  }
    
}
