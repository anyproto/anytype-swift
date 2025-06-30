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
    
    func relationsDetails(keys: [String], spaceId: String) -> [PropertyDetails] {
        return keys.map { PropertyDetails.mock(key: $0) }
    }
    
    func relationsDetails(key: String, spaceId: String) throws -> PropertyDetails {
        PropertyDetails.mock(key: key)
    }
    
    func relationsDetails(bundledKey: BundledPropertyKey, spaceId: String) throws -> PropertyDetails {
        PropertyDetails.mock(key: bundledKey.rawValue)
    }
    
    func relationsDetails(ids: [String], spaceId: String) -> [PropertyDetails] {
        return ids.map { PropertyDetails.mock(id: $0) }
    }
    
    func relationsDetails(spaceId: String) -> [PropertyDetails] {
        fatalError()
    }
    
    func startSubscription(spaceId: String) async {
        fatalError()
    }
    
    func stopSubscription(cleanCache: Bool) async {
        fatalError()
    }
}

extension PropertyDetails {
    static func mock(id: String = "", key: String = "") -> PropertyDetails {
        PropertyDetails(
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
