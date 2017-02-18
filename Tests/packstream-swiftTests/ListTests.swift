import XCTest
@testable import packstream_swift


class ListTests: XCTestCase {

    func testEmptyList() throws {
        // [] -> 90
        XCTFail("Not implemented")
    }

    func testThreeSmallInts() throws {
        // [1, 2, 3] -> 93:01:02:03
        XCTFail("Not implemented")
    }

    func testFourtySmallInts() throws {
        // [1, 2, 3, ... 40] -> D4:28:00:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E:0F:10:11:12:13:14:15:16:17:18:19:1A:1B:1C:1D:1E:1F:20:21:22:23:24:25:26:27
        XCTFail("Not implemented")
    }

    func testTheeHetrogenousTypes() throws {
        // [1, 2.0, "three"] -> 93:01:C1:40:00:00:00:00:00:00:00:85:74:68:72:65:65
        XCTFail("Not implemented")
    }

    func testListOf256Ones() throws {
        // 256 x 0x01 -> D5 01 00 [01 x 256]
        XCTFail("Not implemented")
    }

    func testListOf65536Ones() throws {
        // 65536 x 0x01 -> D6 00 01 00 00 [01 x 65536]
        XCTFail("Not implemented")
    }

    static var allTests : [(String, (ListTests) -> () throws -> Void)] {
        return [
            ("testEmptyList", testEmptyList),
            ("testThreeSmallInts", testThreeSmallInts),
            ("testFourtySmallInts", testFourtySmallInts),
            ("testTheeHetrogenousTypes", testTheeHetrogenousTypes),
            ("testListOf256Ones", testListOf256Ones),
            ("testListOf65536Ones", testListOf65536Ones),
        ]
    }
}
