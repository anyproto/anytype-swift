import SwiftUI

struct DeleteIndicator: View {
    let onTap: () -> ()
    
    var body: some View {
        Button(
            action: onTap,
            label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
        )
    }
}

#Preview {
    DeleteIndicator { }
}
