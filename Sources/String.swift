import Foundation

extension String: PackProtocol {

    struct Constants {
        static let shortStringMinMarker:   Byte = 0x80
        static let shortStringMaxMarker:   Byte = 0x8F

        static let eightBitByteMarker:     Byte = 0xD0
        static let sixteenBitByteMarker:   Byte = 0xD1
        static let thirtytwoBitByteMarker: Byte = 0xD2
    }

    func pack() throws -> [Byte] {

        guard let data = self.data(using: .utf8, allowLossyConversion: false) else {
            throw PackError.notPackable
        }

        var bytes = [Byte]()

        data.withUnsafeBytes { (p: UnsafePointer<UInt8>) -> Void in
            for i in 0..<data.count {
                bytes.append(p[i])
            }
        }

        let n = bytes.count

        if n == 0 {
            return [ 0x80 ]
        } else if n <= 15 {
            return try packShortString(bytes)
        } else if n <= 255 {
            return try pack8BitString(bytes)
        } else if n <= 65535 {
            return try pack16BitString(bytes)
        } else if n <= 4294967295 {
            return try pack32BitString(bytes)
        }

        throw PackError.notPackable
    }

    private func packShortString(_ bytes: [Byte]) throws -> [Byte] {

        let marker = Constants.shortStringMinMarker + UInt8(bytes.count)
        return [marker] + bytes
    }

    private func pack8BitString(_ bytes: [Byte]) throws -> [Byte] {

        let marker = Constants.eightBitByteMarker
        return [marker, UInt8(bytes.count) ] + bytes

    }

    private func pack16BitString(_ bytes: [Byte]) throws -> [Byte] {

        let marker = Constants.sixteenBitByteMarker
        let size = try UInt16(bytes.count).pack()[0...1]
        return [marker] + size + bytes
    }

    private func pack32BitString(_ bytes: [Byte]) throws -> [Byte] {

        let marker = Constants.thirtytwoBitByteMarker
        let size = try UInt32(bytes.count).pack()[0...3]
        return [marker] + size + bytes

    }

    static func unpack(_ bytes: [Byte]) throws -> String {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        switch firstByte {
        case Constants.shortStringMinMarker...Constants.shortStringMaxMarker:
            return try unpackShortString(bytes)
        case Constants.eightBitByteMarker:
            return try unpack8BitString(bytes)
        case Constants.sixteenBitByteMarker:
            return try unpack16BitString(bytes)
        case Constants.thirtytwoBitByteMarker:
            return try unpack32BitString(bytes)
        default:
            throw UnpackError.unexpectedByteMarker
        }
    }

    static func sizeFor(bytes: ArraySlice<Byte>) throws -> Int {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        switch firstByte {
        case Constants.shortStringMinMarker...Constants.shortStringMaxMarker:
            return Int(firstByte) - Int(Constants.shortStringMinMarker)
        case Constants.eightBitByteMarker:
            return Int(try UInt8.unpack(Array(bytes[1..<2])))
        case Constants.sixteenBitByteMarker:
            return Int(try UInt16.unpack(Array(bytes[1..<3])))
        case Constants.thirtytwoBitByteMarker:
            return Int(try UInt32.unpack(Array(bytes[1..<5])))

        default:
            throw UnpackError.unexpectedByteMarker
        }
    }


    private static func unpackShortString(_ bytes: [Byte]) throws -> String {

        let size = bytes[0] - Constants.shortStringMinMarker
        if bytes.count != Int(size) + 1 {
            throw UnpackError.incorrectNumberOfBytes
        }

        if size == 0 {
            return ""
        }

        return try bytesToString(Array(bytes[1..<bytes.count]))
    }

    private static func bytesToString(_ bytes: [Byte]) throws -> String {

        let data = Data(bytes: bytes)
        guard let string = String(data: data, encoding: .utf8) else {
            throw UnpackError.incorrectValue
        }

        return string
    }

    private static func unpack8BitString(_ bytes: [Byte]) throws -> String {

        let size = try UInt8.unpack(Array(bytes[1..<2]))
        if bytes.count != Int(size) + 2 {
            throw UnpackError.incorrectNumberOfBytes
        }

        if size == 0 {
            return ""
        }

        return try bytesToString(Array(bytes[2..<bytes.count]))
    }

    private static func unpack16BitString(_ bytes: [Byte]) throws -> String {

        let size = try UInt16.unpack(Array(bytes[1..<3]))
        if bytes.count != Int(size) + 3 {
            throw UnpackError.incorrectNumberOfBytes
        }

        if size == 0 {
            return ""
        }

        return try bytesToString(Array(bytes[3..<bytes.count]))
    }

    private static func unpack32BitString(_ bytes: [Byte]) throws -> String {

        let size = try UInt32.unpack(Array(bytes[1..<5]))
        if bytes.count != Int(size) + 5 {
            throw UnpackError.incorrectNumberOfBytes
        }

        if size == 0 {
            return ""
        }

        return try bytesToString(Array(bytes[5..<bytes.count]))
    }


}
