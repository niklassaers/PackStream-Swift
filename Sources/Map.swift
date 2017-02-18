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
        return []
    }

    static func unpack(_ bytes: [Byte]) throws -> Map {
        return Map(dictionary: [:])
    }
}
