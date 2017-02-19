import Foundation

typealias Byte = UInt8

protocol PackProtocol {

    func pack() throws -> [Byte]
    static func unpack(_ bytes: [Byte]) throws -> Self
}

enum PackError: Error {
    case notPackable
}

enum UnpackError: Error {
    case incorrectNumberOfBytes
    case incorrectValue
    case unexpectedByteMarker
    case notImplementedYet
}
