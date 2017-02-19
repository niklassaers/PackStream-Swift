import Foundation

struct Map {
    let dictionary: [String: PackProtocol]
}

extension Map: PackProtocol {


    struct Constants {
        static let shortMapMinMarker:   Byte = 0xA0
        static let shortMapMaxMarker:   Byte = 0xAF

        static let eightBitByteMarker:     Byte = 0xD8
        static let sixteenBitByteMarker:   Byte = 0xD9
        static let thirtytwoBitByteMarker: Byte = 0xDA
    }

    func pack() throws -> [Byte] {

        let bytes = try dictionary.map({ (key: PackProtocol, value: PackProtocol) -> [Byte] in
            let keyBytes = try key.pack()
            let valueBytes = try value.pack()
            return keyBytes + valueBytes
        }).reduce([Byte](), { $0 + $1 })

        /*
        let sortedKeys = Array(dictionary.keys).sorted(by: <) // For tests, we need to sort by key
        let bytes = try sortedKeys.map({ key -> [Byte] in
            let keyBytes = try key.pack()
            let value = dictionary[key]
            let valueBytes = try value!.pack()
            return keyBytes + valueBytes
        }).reduce([Byte](), { $0 + $1 })
        */

        switch dictionary.count {
        case 0:
            return [ Constants.shortMapMinMarker ]

        case 1...15:
            return [ Constants.shortMapMinMarker + UInt8(dictionary.count) ] + bytes

        case 16...255:
            let size = try UInt8(dictionary.count).pack()
            return [ Constants.eightBitByteMarker ] + size + bytes

        case 256...65_535:
            let size = try UInt16(dictionary.count).pack()
            return [ Constants.sixteenBitByteMarker ] + size + bytes

        case 65_536...4_294_967_295:
            let size = try UInt32(dictionary.count).pack()
            return [ Constants.thirtytwoBitByteMarker ] + size + bytes

        default:
            throw PackError.notPackable
        }
    }

    static func unpack(_ bytes: [Byte]) throws -> Map {

        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        let size: UInt64
        var position: Int

        switch firstByte {
        case Constants.shortMapMinMarker...Constants.shortMapMaxMarker:
            size = UInt64(firstByte - Constants.shortMapMinMarker)
            position = 1
        case Constants.eightBitByteMarker:
            size = UInt64(try UInt8.unpack([bytes[1]]))
            position = 2
        case Constants.sixteenBitByteMarker:
            size = UInt64(try UInt16.unpack(Array(bytes[1...2])))
            position = 3
        case Constants.thirtytwoBitByteMarker:
            size = UInt64(try UInt32.unpack(Array(bytes[1...4])))
            position = 5
        default:
            throw UnpackError.incorrectValue
        }

        var dictionary = [String:PackProtocol]()
        for _ in 0..<size {
            let key: PackProtocol
            let keyMarkerByte = bytes[position]
            switch Packer.Representations.typeFrom(representation: keyMarkerByte) {
            case .null:
                key = Null()
                position += 1
            case .bool:
                key = try Bool.unpack([keyMarkerByte])
                position += 1
            case .int8small:
                key = try Int8.unpack([keyMarkerByte])
                position += 1
            case .int8:
                key = try Int8.unpack(Array(bytes[position...(position+1)]))
                position += 2
            case .int16:
                key = try Int16.unpack(Array(bytes[position...(position+2)]))
                position += 3
            case .int32:
                key = try Int32.unpack(Array(bytes[position...(position+4)]))
                position += 5
            case .int64:
                key = try Int32.unpack(Array(bytes[position...(position+8)]))
                position += 9
            case .float:
                key = try Double.unpack(Array(bytes[position...(position+8)]))
                position += 9
            case .string:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let sizeBytes = bytes[position..<(position+length)]
                let size = try String.sizeFor(bytes: sizeBytes)
                let markerLength = try String.markerSizeFor(bytes: sizeBytes)
                key = try String.unpack(Array(bytes[position..<(position+markerLength+size)]))
                position += markerLength + size
            case .list:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try List.sizeFor(bytes: bytes[position..<(position+length)])
                key = try List.unpack(Array(bytes[position..<(position+size)]))
                position += size
            case .map:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Map.sizeFor(bytes: bytes[position...(position+length)])
                key = try Map.unpack(Array(bytes[position..<(position+size)]))
                position += size
            case .structure:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Structure.sizeFor(bytes: bytes[position...(position+length)])
                key = try Structure.unpack(Array(bytes[position..<(position+size)]))
                position += size
            }

            let value: PackProtocol
            let valueMarkerByte = bytes[position]
            switch Packer.Representations.typeFrom(representation: valueMarkerByte) {
            case .null:
                value = Null()
                position += 1
            case .bool:
                value = try Bool.unpack([valueMarkerByte])
                position += 1
            case .int8small:
                value = try Int8.unpack([valueMarkerByte])
                position += 1
            case .int8:
                value = try Int8.unpack(Array(bytes[position...(position+1)]))
                position += 2
            case .int16:
                value = try Int16.unpack(Array(bytes[position...(position+2)]))
                position += 3
            case .int32:
                value = try Int32.unpack(Array(bytes[position...(position+4)]))
                position += 5
            case .int64:
                value = try Int32.unpack(Array(bytes[position...(position+8)]))
                position += 9
            case .float:
                value = try Double.unpack(Array(bytes[position...(position+8)]))
                position += 9
            case .string:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let sizeBytes = bytes[position..<(position+length)]
                let size = try String.sizeFor(bytes: sizeBytes)
                let markerLength = try String.markerSizeFor(bytes: sizeBytes)
                value = try String.unpack(Array(bytes[position..<(position+markerLength+size)]))
                position += markerLength + size
            case .list:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try List.sizeFor(bytes: bytes[position..<(position+length)])
                value = try List.unpack(Array(bytes[position..<(position+size)]))
                position += size
            case .map:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Map.sizeFor(bytes: bytes[position...(position+length)])
                value = try Map.unpack(Array(bytes[position..<(position+size)]))
                position += size
            case .structure:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Structure.sizeFor(bytes: bytes[position...(position+length)])
                value = try Structure.unpack(Array(bytes[position..<(position+size)]))
                position += size
            }

            if let key = key as? String {
                dictionary[key] = value
            } else {
                // Only string as key for now, need to make those other keys serve as Map keys
                throw UnpackError.notImplementedYet
            }

        }

        return Map(dictionary: dictionary)
    }

    static func sizeFor(bytes: ArraySlice<Byte>) throws -> Int {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }

        let numberOfItems: Int
        var position: Int
        switch firstByte {
        case Constants.shortMapMinMarker...Constants.shortMapMaxMarker:
            numberOfItems = Int(firstByte) - Int(Constants.shortMapMinMarker)
            position = 1
        case Constants.eightBitByteMarker:
            numberOfItems = Int(try UInt8.unpack(Array(bytes[1..<2])))
            position = 2
        case Constants.sixteenBitByteMarker:
            numberOfItems = Int(try UInt16.unpack(Array(bytes[1..<3])))
            position = 3
        case Constants.thirtytwoBitByteMarker:
            numberOfItems = Int(try UInt32.unpack(Array(bytes[1..<5])))
            position = 5
        default:
            throw UnpackError.unexpectedByteMarker
        }

        for _ in 0..<numberOfItems {
            let keyMarkerByte = bytes[position]
            switch Packer.Representations.typeFrom(representation: keyMarkerByte) {
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
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Map.sizeFor(bytes: bytes[position...(position+length)])
                position += size
            case .structure:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Structure.sizeFor(bytes: bytes[position...(position+length)])
                position += size
            }

            let valueMarkerByte = bytes[position]
            switch Packer.Representations.typeFrom(representation: valueMarkerByte) {
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
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Map.sizeFor(bytes: bytes[position...(position+length)])
                position += size
            case .structure:
                let length = bytes.count > position + 9 ? 9 : bytes.count - position
                let size = try Structure.sizeFor(bytes: bytes[position...(position+length)])
                position += size
            }

        }

        return position
    }
}

extension Map: Equatable {

    static func ==(lhs: Map, rhs: Map) -> Bool {
        if lhs.dictionary.count != rhs.dictionary.count {
            return false
        }

        for key in lhs.dictionary.keys {
            let lhv = lhs.dictionary[key]
            let rhv = rhs.dictionary[key]
            if lhv == nil || rhv == nil {
                return false
            }

            let lht = type(of: lhv)
            let rht = type(of: rhv)

            if lht != rht {
                return false
            }

            if  let l = lhv as? Int8,
                let r = rhv as? Int8,
                l != r {
                return false
            }

            if  let l = lhv as? Int16,
                let r = rhv as? Int16,
                l != r {
                return false
            }

            if  let l = lhv as? Int32,
                let r = rhv as? Int32,
                l != r {
                return false
            }

            if  let l = lhv as? Int64,
                let r = rhv as? Int64,
                l != r {
                return false
            }

            if  let l = lhv as? Bool,
                let r = rhv as? Bool,
                l != r {
                return false
            }

            if  let l = lhv as? Double,
                let r = rhv as? Double,
                l != r {
                return false
            }

            if  let l = lhv as? String,
                let r = rhv as? String,
                l != r {
                return false
            }

            if  let l = lhv as? List,
                let r = rhv as? List,
                l != r {
                return false
            }

            if  let l = lhv as? Map,
                let r = rhv as? Map,
                l != r {
                return false
            }
        }

        return true
    }

}

extension Dictionary {
    func mapDictionary(transform: (Key, Value) -> (Key, Value)?) -> Dictionary<Key, Value> {
        var dict = [Key: Value]()
        for key in keys {
            guard let value = self[key], let keyValue = transform(key, value) else {
                continue
            }

            dict[keyValue.0] = keyValue.1
        }
        return dict
    }
}
