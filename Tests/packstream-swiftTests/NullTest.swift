import XCTest
@testable import packstream_swift


class NullTests: XCTestCase {

    func testNull() throws {
        let val = Null()
        let bytes = try val.pack()
        let unpacked = try Null.unpack(bytes)
        XCTAssert(type(of: val) == type(of: unpacked))
    }

    func testFailOnBadBytes() {

        do {
            let bytes = [ Byte(0x00) ]
            let _ = try Null.unpack(bytes)
        } catch {
            return // Test success
        }

        XCTFail("Should have reached exception")

    }

    static var allTests : [(String, (NullTests) -> () throws -> Void)] {
        return [
            ("testNull", testNull),
            ("testFailOnBadBytes", testFailOnBadBytes),
        ]
    }

}
