import XCTest
@testable import packstream_swift


class BoolTests: XCTestCase {

    func testTrue() throws {
        let val = true
        let bytes = try val.pack()
        let unpacked = try Bool.unpack(bytes)
        XCTAssertEqual(val, unpacked)
    }

    func testFalse() throws {
        let val = false
        let bytes = try val.pack()
        let unpacked = try Bool.unpack(bytes)
        XCTAssertEqual(val, unpacked)
    }

    func testFailOnBadBytes() {

        do {
            let bytes = [ Byte(0x00) ]
            let _ = try Bool.unpack(bytes)
        } catch {
            return // Test success
        }

        XCTFail("Should have reached exception")

    }

    static var allTests : [(String, (BoolTests) -> () throws -> Void)] {
        return [
            ("testTrue", testTrue),
            ("testFalse", testFalse),
            ("testFailOnBadBytes", testFailOnBadBytes),
        ]
    }

}
