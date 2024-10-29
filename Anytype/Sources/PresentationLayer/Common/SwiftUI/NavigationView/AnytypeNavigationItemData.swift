import Foundation
import SwiftUI

struct AnytypeNavigationItemDataEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyHashable? = nil
}

extension EnvironmentValues {
    var anytypeNavigationItemData: AnyHashable? {
        get { self[AnytypeNavigationItemDataEnvironmentKey.self] }
        set { self[AnytypeNavigationItemDataEnvironmentKey.self] = newValue }
    }
}

extension View {
    func anytypeNavigationItemData(_ data: AnyHashable) -> some View {
        environment(\.anytypeNavigationItemData, data)
    }
}
