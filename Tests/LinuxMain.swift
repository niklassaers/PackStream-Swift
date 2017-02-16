import XCTest
@testable import packstream_swiftTests

XCTMain([
     testCase(packstream_swiftTests.allTests),
     testCase(BoolTests.allTests),
     testCase(Int8Tests.allTests),
     testCase(Int16Tests.allTests),
     testCase(Int32Tests.allTests),
     testCase(Int64Tests.allTests),
])
