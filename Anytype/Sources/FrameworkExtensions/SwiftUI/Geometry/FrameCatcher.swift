import SwiftUI

extension View {
    func readFrame(space: CoordinateSpace = .global, _ onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            FrameCatcher(space: space, onChange: onChange)
        )
    }
}

struct FrameCatcher: View {
    var space: CoordinateSpace = .global
    let onChange: (CGRect) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: FrameCatcherKey.self,
                value: geometry.frame(in: space)
            )
        }
        .onPreferenceChange(FrameCatcherKey.self) {
            onChange($0)
        }
    }
}

struct FrameCatcherKey: PreferenceKey {
    static let defaultValue = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
