import SwiftUI

public struct AttentionDotView: View {
    public init() { }

    public var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.Control.accent100)
                .frame(width: 8, height: 8)

            Circle()
                .strokeBorder(Color.Background.primary, lineWidth: 2)
                .frame(width: 10, height: 10)
        }
    }
}

#Preview {
    AttentionDotView()
}
