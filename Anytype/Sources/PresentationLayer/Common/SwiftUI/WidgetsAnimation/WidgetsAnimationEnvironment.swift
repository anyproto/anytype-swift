import SwiftUI

private struct WidgetsAnimationNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var widgetsAnimationNamespace: Namespace.ID? {
        get { self[WidgetsAnimationNamespaceKey.self] }
        set { self[WidgetsAnimationNamespaceKey.self] = newValue }
    }
}

extension View {
    func widgetsAnimationNamespace(_ namespace: Namespace.ID?) -> some View {
        environment(\.widgetsAnimationNamespace, namespace)
    }
}
