import Foundation
import SwiftUI

final class AnytypeDestinationBuilderHolder {
    
    private var builders: [String: (Any) -> AnyView?] = [:]
    
    static func identifier(for type: Any.Type) -> String {
        String(reflecting: type)
    }
    
    func appendBuilder<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) {
        return appendBuilder({ AnyView(builder($0)) })
    }
    
    func appendBuilder<T>(_ builder: @escaping (T) -> AnyView) {
        let key = Self.identifier(for: T.self)
        builders[key] = { data in
            if let typedData = data as? T {
                return builder(typedData)
            } else {
                return nil
            }
        }
    }
    
    @MainActor
    func build(_ typedData: Any) -> AnyView {
        let key = Self.identifier(for: type(of: typedData))
        if let builder = builders[key], let view = builder(typedData) {
            return view
        }
        assertionFailure("No view builder found for type \(key)")
        return EmptyView().eraseToAnyView()
    }
}
