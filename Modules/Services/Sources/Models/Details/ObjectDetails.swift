import Foundation
import AnytypeCore
import SwiftProtobuf

public struct ObjectDetails: Hashable, RelationValueProvider, BundledRelationsValueProvider {
    
    public let id: BlockId
    public let values: [String: Google_Protobuf_Value]
    
    public init(id: BlockId, values: [String: Google_Protobuf_Value]) {
        self.id = id
        self.values = values
    }
    
}

public extension ObjectDetails {
    
    init(id: BlockId) {
        self.id = id
        self.values = [:]
    }
    
}

public extension ObjectDetails {
    
    func updated(by rawDetails: [String: Google_Protobuf_Value]) -> ObjectDetails {
        guard !rawDetails.isEmpty else { return self }
        
        let newValues = self.values.merging(rawDetails) { (_, new) in new }
        
        return ObjectDetails(id: self.id, values: newValues)
    }
    
    func removed(keys: [String]) -> ObjectDetails {
        guard keys.isNotEmpty else { return self }
        
        var currentValues = self.values
        
        keys.forEach {
            currentValues.removeValue(forKey: $0)
        }
        
        return ObjectDetails(id: self.id, values: currentValues)
    }
    
}

public extension ObjectDetails {
    
    init?(protobufStruct: Google_Protobuf_Struct) {
        let fields = protobufStruct.fields
        
        guard let id = fields["id"]?.stringValue, id.isValidId else {
            anytypeAssertionFailure("Empty id in subscription data")
            return nil
        }
        
        self.init(id: id, values: fields)
    }
}
