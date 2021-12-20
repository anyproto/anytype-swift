import SwiftUI

extension View {
  func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
    background(
        SizeCatcher(onChange: onChange)
    )
  }
}

private struct SizeCatcher: View {
    let onChange: (CGSize) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: FrameCatcherKey.self,
                value: geometry.size
            )
        }
        .onPreferenceChange(FrameCatcherKey.self) {
            onChange($0)
        }
    }
}

private struct FrameCatcherKey: PreferenceKey {
    static var defaultValue = CGSize.zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
