import Foundation
import AnytypeCore
import AsyncTools

protocol ExperementalFeaturesStorageProtocol: AnyObject, Sendable {
    var newObjectCreationMenuSequence: AnyAsyncSequence<Bool> { get }
    var newObjectCreationMenu: Bool { get set }
}

final class ExperementalFeaturesStorage: ExperementalFeaturesStorageProtocol, Sendable {
    
    private let newObjectCreationMenuStorage = FeatureStorage(key: "ExperementalFeatures.newObjectCreationMenu", defaultValue: false)
    
    var newObjectCreationMenuSequence: AnyAsyncSequence<Bool> {
        newObjectCreationMenuStorage.sequence
    }
    
    var newObjectCreationMenu: Bool {
        get { newObjectCreationMenuStorage.value }
        set { newObjectCreationMenuStorage.value = newValue }
    }
}

// MARK: - Private storage

fileprivate final class FeatureStorage<Value: Codable & Sendable>: Sendable {
    
    private let storage: UserDefaultStorage<Value>
    private let stream = AsyncToManyStream<Value>()
    
    var sequence: AnyAsyncSequence<Value> {
        stream.eraseToAnyAsyncSequence()
    }
    
    var value: Value {
        get { storage.value }
        set {
            storage.value = newValue
            stream.send(newValue)
        }
    }
    
    init(key: String, defaultValue: Value) {
        storage = UserDefaultStorage(key: key, defaultValue: defaultValue)
        stream.send(storage.value)
    }
}
