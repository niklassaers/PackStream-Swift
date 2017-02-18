import Foundation

struct Null {}

extension Null : PackProtocol {

    struct Constants {
        static let byteMarker: Byte = 0xC0
    }


    func pack() throws -> [Byte] {
        return [ Constants.byteMarker ]
    }

    static func unpack(_ bytes: [Byte]) throws -> Null {
        if bytes.count != 1 {
            throw UnpackError.incorrectNumberOfBytes
        }

        if bytes[0] != Constants.byteMarker {
            throw UnpackError.unexpectedByteMarker
        }

        return Null()
    }

}
