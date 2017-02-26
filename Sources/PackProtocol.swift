import Foundation

public typealias Byte = UInt8

public protocol PackProtocol {

    func pack() throws -> [Byte]
    static func unpack(_ bytes: [Byte]) throws -> Self
}

public enum PackError: Error {
    case notPackable
}

public enum UnpackError: Error {
    case incorrectNumberOfBytes
    case incorrectValue
    case unexpectedByteMarker
    case notImplementedYet
}
