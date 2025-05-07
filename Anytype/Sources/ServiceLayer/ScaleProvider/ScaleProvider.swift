import Foundation
import AnytypeCore

// Provider for reading scale not from main thread.
final class ScaleProvider: @unchecked Sendable {
    
    static let shared = ScaleProvider()
    
    private let scaleStorage = AtomicStorage<CGFloat>(0)
    
    private init() {}
    
    var scale: CGFloat {
        get { scaleStorage.value }
        set { scaleStorage.value = newValue }
    }
    
}
