@testable import Anytype
import Foundation
import Combine
import Services


final class MockPropertyDetailsStorage: PropertyDetailsStorageProtocol {
    // Publisher for sync events
    private let syncSubject = PassthroughSubject<Void, Never>()
    var syncPublisher: AnyPublisher<Void, Never> {
        return syncSubject.eraseToAnyPublisher()
    }
    
    func relationsDetails(keys: [String], spaceId: String) -> [RelationDetails] {
        return keys.map { RelationDetails.mock(key: $0) }
    }
    
    func relationsDetails(key: String, spaceId: String) throws -> RelationDetails {
        RelationDetails.mock(key: key)
    }
    
    func relationsDetails(bundledKey: BundledPropertyKey, spaceId: String) throws -> RelationDetails {
        RelationDetails.mock(key: bundledKey.rawValue)
    }
    
    func relationsDetails(ids: [String], spaceId: String) -> [RelationDetails] {
        return ids.map { RelationDetails.mock(id: $0) }
    }
    
    func relationsDetails(spaceId: String) -> [RelationDetails] {
        fatalError()
    }
    
    func startSubscription(spaceId: String) async {
        fatalError()
    }
    
    func stopSubscription(cleanCache: Bool) async {
        fatalError()
    }
}

extension RelationDetails {
    static func mock(id: String = "", key: String = "") -> RelationDetails {
        RelationDetails(
            id: id,
            key: key,
            name: "name",
            format: .number,
            isHidden: false,
            isReadOnly: false,
            isReadOnlyValue: false,
            objectTypes: [],
            maxCount: 0,
            sourceObject: "",
            isDeleted: false,
            spaceId: ""
        )
    }
}
