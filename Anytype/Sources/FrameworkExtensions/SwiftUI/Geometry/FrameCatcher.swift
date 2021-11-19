import SwiftUI

struct FrameCatcher: View {
    let onChange: (CGRect) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: FrameCatcherKey.self,
                value: geometry.frame(in: .global)
            )
        }
        .onPreferenceChange(FrameCatcherKey.self) {
            onChange($0)
        }
    }
}


struct FrameCatcherKey: PreferenceKey {
    static var defaultValue = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
