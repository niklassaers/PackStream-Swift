import Foundation

struct List {
    
}

extension List: PackProtocol {
    
    func pack() throws -> [Byte] {
        
        return []
    }
    
    static func unpack(_ bytes: [Byte]) throws -> List {
        
        return List()
    }
}
