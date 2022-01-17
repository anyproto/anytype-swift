import SwiftUI

struct SetHeaderSettings: View {
    let settingsHeight: CGFloat = 56
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        Button(action: { model.showViewPicker = true }) {
            HStack {
                AnytypeText(model.activeView.name, style: .heading, color: .textPrimary)
                    .padding()
                Image.arrow.rotationEffect(.degrees(90))
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
