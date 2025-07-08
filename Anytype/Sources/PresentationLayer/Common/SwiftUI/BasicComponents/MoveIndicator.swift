import SwiftUI

struct MoveIndicator: View {
    var body: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 20))
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(.Pure.grey.opacity(0.5))
            .frame(width: 30, height: 30) // Fixed frame to match system size
            .contentShape(Rectangle())
    }
}
#Preview {
    MoveIndicator()
}
