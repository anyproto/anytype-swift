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
                key: SizeCatcherKey.self,
                value: geometry.size
            )
        }
        .onPreferenceChange(SizeCatcherKey.self) {
            onChange($0)
        }
    }
}

private struct SizeCatcherKey: PreferenceKey {
    static let defaultValue = CGSize.zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
