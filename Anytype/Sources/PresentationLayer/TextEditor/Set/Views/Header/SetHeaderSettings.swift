import SwiftUI

struct SetHeaderSettings: View {
    let settingsHeight: CGFloat = 56
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.fastSpring) {
                model.showViewPicker = true
            }
        }) {
            HStack(spacing: 0) {
                Spacer.fixedWidth(20)
                AnytypeText(model.activeView.name, style: .heading, color: .textPrimary)
                Spacer.fixedWidth(5)
                Image.arrowDown
                Spacer()
            }
            .frame(height: settingsHeight)
        }
    }
}

struct SetHeaderSettings_Previews: PreviewProvider {
    static var previews: some View {
        SetHeaderSettings()
    }
}
