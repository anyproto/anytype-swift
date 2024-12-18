import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var anytypeNavigationItemData: AnyHashable? = nil
}

extension View {
    func anytypeNavigationItemData(_ data: AnyHashable) -> some View {
        environment(\.anytypeNavigationItemData, data)
    }
}
