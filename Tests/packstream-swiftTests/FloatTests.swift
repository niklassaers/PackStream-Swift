import XCTest
import Darwin
@testable import packstream_swift


class FloatTests: XCTestCase {
    
    func testMin() throws {
        
        let value = DBL_MIN
        let bytes = try value.pack()
        XCTAssertEqual(9, bytes.count)
        
        let unpacked = try Double.unpack(bytes)
        XCTAssertEqual(value, unpacked)
    }
    
    func testMax() throws {
        
        let value = DBL_MAX
        let bytes = try value.pack()
        XCTAssertEqual(9, bytes.count)
        
        let unpacked = try Double.unpack(bytes)
        XCTAssertEqual(value, unpacked)
    }
    
    func test42() throws {
        
        let value: Float64 = Float64(42.0)
        let bytes = try value.pack()
        XCTAssertEqual(9, bytes.count)
        XCTAssertEqual(0xC1, bytes[0])
        XCTAssertEqual(0x40, bytes[1]) // what should it be?
        XCTAssertEqual(0x45, bytes[2])
        XCTAssertEqual(0x00, bytes[3])
        XCTAssertEqual(0x00, bytes[4])
        XCTAssertEqual(0x00, bytes[5])
        XCTAssertEqual(0x00, bytes[6])
        XCTAssertEqual(0x00, bytes[7])
        XCTAssertEqual(0x00, bytes[8])
        
        let unpacked = try Float64.unpack(bytes)
        XCTAssertEqual(value, unpacked)

    }
    
    func test_6_283185307179586() throws {
        let value: Float64 = 6.283185307179586
        let bytes = try value.pack()
        XCTAssertEqual(9, bytes.count)
        XCTAssertEqual(0xC1, bytes[0])
        XCTAssertEqual(0x40, bytes[1])
        XCTAssertEqual(0x19, bytes[2])
        XCTAssertEqual(0x21, bytes[3])
        XCTAssertEqual(0xFB, bytes[4])
        XCTAssertEqual(0x54, bytes[5])
        XCTAssertEqual(0x44, bytes[6])
        XCTAssertEqual(0x2D, bytes[7])
        XCTAssertEqual(0x18, bytes[8])
        
        let unpacked = try Float64.unpack(bytes)
        XCTAssertEqual(value, unpacked)
        
    }
    
    func test_1_1() throws {
        let pos: [Byte] = [0xC1, 0x3F, 0xF1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9A]
        let neg: [Byte] = [0xC1, 0xBF, 0xF1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9A]
        
        XCTAssertEqual(Double(1.1), try Double.unpack(pos))
        XCTAssertEqual(Double(-1.1), try Double.unpack(neg))
    }
    
    static var allTests : [(String, (FloatTests) -> () throws -> Void)] {
        return [
            
            ("testMin", testMin),
            ("testMax", testMax),
            ("test42", test42),
            ("test_6_283185307179586", test_6_283185307179586),
            ("test_1_1", test_1_1),
 
        ]
    }
    
}
