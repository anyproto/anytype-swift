import SwiftUI

struct PositionCatcher: View {
    let onChange: (CGPoint) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: PositionCatcherKey.self,
                value: geometry.frame(in: .global)
            )
        }
        .frame(width: 0, height: 0)
        .onPreferenceChange(PositionCatcherKey.self) { data in
            MainActor.assumeIsolated {
                onChange(data.origin)
            }
        }
    }
}

struct PositionCatcherKey: PreferenceKey {
    static let defaultValue = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
