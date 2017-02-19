import Foundation

struct Structure {
    let signature: UInt8
    let items: [PackProtocol]
}

extension Structure: Equatable {

    static func ==(lhs: Structure, rhs: Structure) -> Bool {
        if lhs.signature != rhs.signature {
            return false
        }

        if lhs.items.count != rhs.items.count {
            return false
        }

        for i in 0..<lhs.items.count {
            let lht = type(of: lhs.items[i])
            let rht = type(of: rhs.items[i])
            if lht != rht {
                return false
            }

            if  let l = lhs.items[i] as? Int8,
                let r = rhs.items[i] as? Int8,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Int16,
                let r = rhs.items[i] as? Int16,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Int32,
                let r = rhs.items[i] as? Int32,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Int64,
                let r = rhs.items[i] as? Int64,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Bool,
                let r = rhs.items[i] as? Bool,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Double,
                let r = rhs.items[i] as? Double,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? String,
                let r = rhs.items[i] as? String,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Structure,
                let r = rhs.items[i] as? Structure,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Map,
                let r = rhs.items[i] as? Map,
                l != r {
                return false
            }

            if  let l = lhs.items[i] as? Structure,
                let r = rhs.items[i] as? Structure,
                l != r {
                return false
            }
        }

        return true
    }

}

extension Structure: PackProtocol {


    struct Constants {
        static let shortStructureMinMarker:   Byte = 0xB0
        static let shortStructureMaxMarker:   Byte = 0xBF

        static let eightBitByteMarker:     Byte = 0xDC
        static let sixteenBitByteMarker:   Byte = 0xDD
    }

    func pack() throws -> [Byte] {

        switch items.count {
        case 0:
            return [ Constants.shortStructureMinMarker, signature ]
        case 1...15:
            let bytes: [Byte] = try items.map({ try $0.pack() }).reduce([Byte](), { $0 + $1 })
            return [ Constants.shortStructureMinMarker + UInt8(items.count), signature ] + bytes
        case 16...255:
            let bytes: [Byte] = try items.map({ try $0.pack() }).reduce([Byte](), { $0 + $1 })
            let size = try UInt8(items.count).pack()
            return [ Constants.eightBitByteMarker ] + size + [ signature ] + bytes
        case 256...65_535:
            let bytes: [Byte] = try items.map({ try $0.pack() }).reduce([Byte](), { $0 + $1 })
            let size = try UInt16(items.count).pack()
            return [ Constants.sixteenBitByteMarker ] + size + [ signature ] + bytes
        default:
            throw PackError.notPackable
        }
    }

    static func unpack(_ bytes: [Byte]) throws -> Structure {

        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        let size: UInt64
        var position: Int

        switch firstByte {
        case Constants.shortStructureMinMarker...Constants.shortStructureMaxMarker:
            size = UInt64(firstByte - Constants.shortStructureMinMarker)
            position = 1
        case Constants.eightBitByteMarker:
            size = UInt64(try UInt8.unpack([bytes[1]]))
            position = 2
        case Constants.sixteenBitByteMarker:
            size = UInt64(try UInt16.unpack(Array(bytes[1...2])))
            position = 3
        default:
            throw UnpackError.incorrectValue
        }

        let signature: UInt8 = bytes[position]
        if signature > 127 {
            throw UnpackError.incorrectValue
        }
        position += 1

        var items = [PackProtocol]()
        for _ in 0..<size {
            let item: PackProtocol
            let markerByte = bytes[position]
            switch Packer.Representations.typeFrom(representation: markerByte) {
            case .null:
                item = Null()
                position += 1
            case .bool:
                item = try Bool.unpack([markerByte])
                position += 1
            case .int8small:
                item = try Int8.unpack([markerByte])
                position += 1
            case .int8:
                item = try Int8.unpack(Array(bytes[position...(position+1)]))
                position += 2
            case .int16:
                item = try Int16.unpack(Array(bytes[position...(position+2)]))
                position += 3
            case .int32:
                item = try Int32.unpack(Array(bytes[position...(position+4)]))
                position += 5
            case .int64:
                item = try Int32.unpack(Array(bytes[position...(position+8)]))
                position += 9
            case .float:
                item = try Double.unpack(Array(bytes[position...(position+8)]))
                position += 9
            case .string:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let sizeBytes = bytes[position..<(position+length)]
                let size = try String.sizeFor(bytes: sizeBytes)
                let markerLength = try String.markerSizeFor(bytes: sizeBytes)
                item = try String.unpack(Array(bytes[position..<(position+markerLength+size)]))
                position += markerLength + size
            case .list:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Structure.sizeFor(bytes: bytes[position..<(position+length)])
                item = try Structure.unpack(Array(bytes[position..<(position+size)]))
                position += size
            case .map:
                throw UnpackError.notImplementedYet
            case .structure:
                throw UnpackError.notImplementedYet
            }

            items.append(item)
        }

        return Structure(signature: signature, items: items)
    }

    static func sizeFor(bytes: ArraySlice<Byte>) throws -> Int {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        let numberOfItems: Int
        var position: Int
        switch firstByte {
        case Constants.shortStructureMinMarker...Constants.shortStructureMaxMarker:
            numberOfItems = Int(firstByte) - Int(Constants.shortStructureMinMarker)
            position = 1
        case Constants.eightBitByteMarker:
            numberOfItems = Int(try UInt8.unpack(Array(bytes[1..<2])))
            position = 2
        case Constants.sixteenBitByteMarker:
            numberOfItems = Int(try UInt16.unpack(Array(bytes[1..<3])))
            position = 3
        default:
            throw UnpackError.unexpectedByteMarker
        }

        for _ in 0..<numberOfItems {
            let markerByte = bytes[position]
            switch Packer.Representations.typeFrom(representation: markerByte) {
            case .null:
                position += 1
            case .bool:
                position += 1
            case .int8small:
                position += 1
            case .int8:
                position += 2
            case .int16:
                position += 3
            case .int32:
                position += 5
            case .int64:
                position += 9
            case .float:
                position += 9
            case .string:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try String.sizeFor(bytes: bytes[position...(position+length)])
                position += size
            case .list:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try List.sizeFor(bytes: bytes[position...(position+length)])
                position += size
            case .map:
                throw UnpackError.notImplementedYet
            case .structure:
                throw UnpackError.notImplementedYet
            }
        }

        return position
    }

}
