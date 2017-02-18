import Foundation

extension Int8: PackProtocol {
    struct Constants {
        static let byteMarker: Byte = 0xC8
    }

    func pack() throws -> [Byte] {

        switch self {
        case -0x10 ... 0x7F:
            return packInt8(withByteMarker: false)
        default:
            return packInt8(withByteMarker: true)
        }
    }

    static func unpack(_ bytes: [Byte]) throws -> Int8 {

        switch bytes.count {
        case 1:
            return try unpackInt8(bytes, withMarker: false)
        case 2:
            return try unpackInt8(bytes, withMarker: true)
        default:
            throw UnpackError.incorrectNumberOfBytes
        }
    }

    private func packInt8(withByteMarker: Bool) -> [Byte] {

        if withByteMarker == true {
            return [ Constants.byteMarker, Byte(bitPattern: self) ]
        } else {
            return [ Byte(bitPattern: self) ]
        }
    }

    private static func unpackInt8(_ bytes: [Byte], withMarker: Bool) throws -> Int8 {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        if withMarker == false {
            return Int8(bitPattern: firstByte)

        } else {
            if firstByte != Constants.byteMarker {
                throw UnpackError.unexpectedByteMarker
            }

            if bytes.count != 2 {
                throw UnpackError.incorrectNumberOfBytes
            }

            let byte: Byte = bytes[1]
            return Int8(bitPattern: byte)
        }
    }

}

extension Int16: PackProtocol {
    struct Constants {
        static let byteMarker: Byte = 0xC9
    }

    func pack() throws -> [Byte] {

        let nv: Int16 = Int16(self).bigEndian
        let uNv = UInt16(bitPattern: nv)

        let second = UInt8(uNv >> 8)
        let first = UInt8(uNv & 0x00ff)

        return [ Constants.byteMarker, first, second ]
    }

    static func unpack(_ bytes: [Byte]) throws -> Int16 {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        if firstByte != Constants.byteMarker {
            throw UnpackError.unexpectedByteMarker
        }

        if bytes.count != 3 {
            throw UnpackError.incorrectNumberOfBytes
        }

        let data = NSData(bytes: bytes, length: 3)
        let i: Int16 = Int.readInteger(data: data, start: 1)
        return Int16(bigEndian: i)
    }

}

extension UInt8 {

    func pack() throws -> [Byte] {
        return [ self ]
    }

    static func unpack(_ bytes: [Byte]) throws -> UInt8 {
        if bytes.count != 1 {
            throw UnpackError.incorrectNumberOfBytes
        }

        return bytes[0]
    }
}

extension UInt16 {

    func pack() throws -> [Byte] {
        var i: UInt16 = UInt16(self).bigEndian
        let data = NSData(bytes: &i, length: MemoryLayout<UInt16>.size)
        let length = data.length

        var bytes = [Byte](repeating: 0, count: length)
        data.getBytes(&bytes, length: length)
        return bytes
    }

    static func unpack(_ bytes: [Byte]) throws -> UInt16 {

        if bytes.count != 2 {
            throw UnpackError.incorrectNumberOfBytes
        }

        let data = NSData(bytes: bytes, length: 2)
        let i: UInt16 = Int.readInteger(data: data, start: 0)
        return UInt16(bigEndian: i)
    }

}


extension UInt32 {

    func pack() throws -> [Byte] {
        var i: UInt32 = UInt32(self).bigEndian
        let data = NSData(bytes: &i, length: MemoryLayout<UInt32>.size)
        let length = data.length

        var bytes = [Byte](repeating: 0, count: length)
        data.getBytes(&bytes, length: length)
        return bytes
    }

    static func unpack(_ bytes: [Byte]) throws -> UInt32 {

        if bytes.count != 4 {
            throw UnpackError.incorrectNumberOfBytes
        }

        let data = NSData(bytes: bytes, length: 4)
        let i: UInt32 = Int.readInteger(data: data, start: 0)
        return UInt32(bigEndian: i)
    }

}

extension Int32: PackProtocol {
    struct Constants {
        static let byteMarker: Byte = 0xCA
    }

    func pack() throws -> [Byte] {
        var i: Int32 = Int32(self).bigEndian
        let data = NSData(bytes: &i, length: MemoryLayout<Int32>.size)
        let length = data.length

        var bytes = [Byte](repeating: 0, count: length)
        data.getBytes(&bytes, length: length)
        return [Constants.byteMarker] + bytes
    }

    static func unpack(_ bytes: [Byte]) throws -> Int32 {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        if firstByte != Constants.byteMarker {
            throw UnpackError.unexpectedByteMarker
        }

        if bytes.count != 5 {
            throw UnpackError.incorrectNumberOfBytes
        }

        let data = NSData(bytes: bytes, length: 5)
        let i: Int32 = Int.readInteger(data: data, start: 1)
        return Int32(bigEndian: i)
    }
}

extension Int64: PackProtocol {
    struct Constants {
        static let byteMarker: Byte = 0xCB
    }

    func pack() throws -> [Byte] {

        var i: Int64 = Int64(self).bigEndian
        let data = NSData(bytes: &i, length: MemoryLayout<Int64>.size)
        let length = data.length

        var bytes = [Byte](repeating: 0, count: length)
        data.getBytes(&bytes, length: length)
        return [Constants.byteMarker] + bytes
    }

    static func unpack(_ bytes: [Byte]) throws -> Int64 {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        if firstByte != Constants.byteMarker {
            throw UnpackError.unexpectedByteMarker
        }

        if bytes.count != 9 {
            throw UnpackError.incorrectNumberOfBytes
        }

        let data = NSData(bytes: bytes, length: 9)
        let i: Int64 = Int.readInteger(data: data, start: 1)
        return Int64(bigEndian: i)
    }

}



extension Int: PackProtocol {


    func pack() throws -> [Byte] {

        switch self {
        case -0x10 ... 0x7F:
            return try Int8(self).pack()
        case -0x7F ..< -0x7F:
            return try Int8(self).pack()
        case -0x8000 ..< 0x8000:
            return try Int16(self).pack()
        case -0x80000000 ..< 0x80000000:
            return try Int32(self).pack()
        case -0x8000000000000000 ... (0x800000000000000 - 1):
            return try Int64(self).pack()
        default:
            throw PackError.notPackable
        }
    }

    static func unpack(_ bytes: [Byte]) throws -> Int {

        switch bytes.count {
        case 1:
            return Int(try Int8.unpack(bytes))
        case 2:
            return Int(try Int8.unpack(bytes))
        case 3:
            return Int(try Int16.unpack(bytes))
        case 5:
            return Int(try Int32.unpack(bytes))
        case 9:
            return Int(try Int64.unpack(bytes))
        default:
            throw UnpackError.incorrectNumberOfBytes
        }
    }

    static func readInteger<T : Integer>(data : NSData, start : Int) -> T {
        var d : T = 0
        data.getBytes(&d, range: NSRange(location: start, length: MemoryLayout<T>.size))
        return d
    }


}
