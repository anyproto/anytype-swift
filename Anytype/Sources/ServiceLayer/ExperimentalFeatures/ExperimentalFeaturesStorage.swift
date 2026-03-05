import Foundation
import AnytypeCore
import AsyncTools

protocol ExperimentalFeaturesStorageProtocol: AnyObject, Sendable {
    var newObjectCreationMenuSequence: AnyAsyncSequence<Bool> { get }
    var newObjectCreationMenu: Bool { get set }
    var hideReadPreviewsSequence: AnyAsyncSequence<Bool> { get }
    var hideReadPreviews: Bool { get set }
}

final class ExperimentalFeaturesStorage: ExperimentalFeaturesStorageProtocol, Sendable {

    private let newObjectCreationMenuStorage = FeatureStorage(key: "ExperimentalFeaturesStorage.newObjectCreationMenu", defaultValue: true)
    private let hideReadPreviewsStorage = FeatureStorage(key: "ExperimentalFeaturesStorage.compactVault", defaultValue: true)

    var newObjectCreationMenuSequence: AnyAsyncSequence<Bool> {
        newObjectCreationMenuStorage.sequence
    }

    var newObjectCreationMenu: Bool {
        get { newObjectCreationMenuStorage.value }
        set { newObjectCreationMenuStorage.value = newValue }
    }

    var hideReadPreviewsSequence: AnyAsyncSequence<Bool> {
        hideReadPreviewsStorage.sequence
    }

    var hideReadPreviews: Bool {
        get { hideReadPreviewsStorage.value }
        set { hideReadPreviewsStorage.value = newValue }
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
