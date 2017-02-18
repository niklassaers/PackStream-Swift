import Foundation

extension Double: PackProtocol {  // a.k.a Float64
    
    struct Constants {
        static let byteMarker: Byte = 0xC1
    }
    
    func pack() throws -> [Byte] {
        let bytes = Double.toByteArray(self).reversed()
        return [Constants.byteMarker] + bytes
    }
    
    static func unpack(_ bytes: [Byte]) throws -> Double {
        guard let firstByte = bytes.first else {
            throw UnpackError.incorrectNumberOfBytes
        }
        
        if firstByte != Constants.byteMarker {
            throw UnpackError.unexpectedByteMarker
        }
        
        if bytes.count != 9 {
            throw UnpackError.incorrectNumberOfBytes
        }
        
        let array = Array(bytes[1...8].reversed())
        let v: Double = Double.fromByteArray(array, Double.self)
        return v
    }
    
    static func toByteArray<T>(_ value: T) -> [Byte] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }
    
    static func fromByteArray<T>(_ value: [Byte], _: T.Type) -> T {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }
}
