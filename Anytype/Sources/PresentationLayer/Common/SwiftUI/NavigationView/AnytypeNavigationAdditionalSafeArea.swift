import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var anytypeNavigationPanelSize = CGSize.zero
}

extension View {
    func anytypeNavigationPanelSize(_ size: CGSize) -> some View {
        environment(\.anytypeNavigationPanelSize, size)
    }
}
