import SwiftUI

extension View {
    func readSafeArea(_ onChange: @escaping (EdgeInsets) -> Void) -> some View {
        background(
            SafeAreaCatcher(onChange: onChange)
        )
    }
}

private struct SafeAreaCatcher: View {
    let onChange: (EdgeInsets) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: SafeAreaCatcherKey.self,
                value: geometry.safeAreaInsets
            )
        }
        .onPreferenceChange(SafeAreaCatcherKey.self) {
            onChange($0)
        }
    }
}

private struct SafeAreaCatcherKey: PreferenceKey {
    static let defaultValue = EdgeInsets()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}
