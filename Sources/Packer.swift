import Foundation

class Packer {

    enum Representations {
        case null
        case bool
        case int

        func typeFrom(representation: Byte) -> Representations {
            switch Int8(representation) {
            case -0x10 ... 0x7F:
                return .int
            default:
                break
            }

            switch representation {
            case 0xC0:
                return .null
            case Bool.Constants.byteForFalse,
                 Bool.Constants.byteForTrue:
                return .bool
            case Int8.Constants.byteMarker,
                 Int16.Constants.byteMarker,
                 Int32.Constants.byteMarker,
                 Int64.Constants.byteMarker:
                return .int
            default:
                return .null
            }
        }
    }

    func pack(_ values: [PackProtocol]) throws -> [Byte] {
        let packed = try values.flatMap { (value) -> [Byte] in
            try value.pack()
        }
        return packed
    }

    func unpack(_ bytes: [Byte]) throws -> [PackProtocol] {

        return []

    }

}
