import Foundation
import AnytypeCore
import SwiftProtobuf

enum ObjectDetailsError: Error {
	case detailsIdIsMissing
}

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
    
    static let deleted = ObjectDetails(
        id: "",
        values: [BundledRelationKey.isDeleted.rawValue: Google_Protobuf_Value(boolValue: true)]
    )
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
    
    init(protobufStruct: Google_Protobuf_Struct) throws {
        let fields = protobufStruct.fields
        
        guard let id = fields["id"]?.stringValue, id.isValidId else {
            anytypeAssertionFailure("Empty id in subscription data")
			throw ObjectDetailsError.detailsIdIsMissing
        }
        
        self.init(id: id, values: fields)
    }
}

public extension ObjectDetails {
    // Should remove when GO-2964 will be fixed
    var restrictionsList: [Int] {
        values[BundledRelationKey.restrictions.rawValue]?
            .listValue.values.compactMap { $0.safeIntValue } ?? []
    }
}
