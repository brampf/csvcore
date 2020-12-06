import XCTest

import CSVTests

var tests = [XCTestCaseEntry]()
tests += CSVTests.allTests()
XCTMain(tests)
