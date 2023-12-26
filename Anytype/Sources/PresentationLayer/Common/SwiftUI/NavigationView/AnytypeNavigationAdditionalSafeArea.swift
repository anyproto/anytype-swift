import Foundation
import SwiftUI

struct AnytypeNavigationPanelSizeEnvironmentKey: EnvironmentKey {
    static let defaultValue = CGSize.zero
}

extension EnvironmentValues {
    var anytypeNavigationPanelSize: CGSize {
        get { self[AnytypeNavigationPanelSizeEnvironmentKey.self] }
        set { self[AnytypeNavigationPanelSizeEnvironmentKey.self] = newValue }
    }
}

extension View {
    func anytypeNavigationPanelSize(_ size: CGSize) -> some View {
        environment(\.anytypeNavigationPanelSize, size)
    }
}
