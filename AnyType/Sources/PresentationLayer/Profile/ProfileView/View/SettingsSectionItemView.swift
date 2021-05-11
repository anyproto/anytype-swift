import SwiftUI

struct SettingsSectionItemView: View {
    @State var name: String
    @State var icon: String
    @Binding var pressed: Bool

    var body: some View {
        HStack(spacing: 8) {
            if !self.icon.isEmpty {
                Image(icon).frame(width: 24.0, height: 24.0)
            }
            AnytypeText(name, style: .bodyBold)
            Spacer()
            Image("arrowForward")
        }
        // Workaround https://www.hackingwithswift.com/quick-start/swiftui/how-to-control-the-tappable-area-of-a-view-using-contentshape
        .contentShape(Rectangle())
        .onTapGesture {
            self.pressed = true
        }
    }
}
