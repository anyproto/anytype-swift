import SwiftUI
import AnytypeCore

struct SetHeaderSettings: View {
    let settingsHeight: CGFloat = 56
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            viewButton
            Spacer()
            settingButton

            if FeatureFlags.redesignNewButton {
                Spacer.fixedWidth(16)
                createObjectButton
            } else {
                Spacer.fixedWidth(24)
                createObjectButtonOld
            }
        }
        .padding(.horizontal, 20)
        .frame(height: settingsHeight)
    }
    
    private var settingButton: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            model.showSetSettings()
        }) {
            Image(asset: .setSettings)
        }
    }

    private var createObjectButtonOld: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            model.createObject()
        }) {
            Image(asset: .plus)
        }
    }
    
    private var createObjectButton: some View {
        SmallButton(icon: .plusWhite12, text: Loc.new) {
            UISelectionFeedbackGenerator().selectionChanged()
            model.createObject()
        }
    }
    
    private var viewButton: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.fastSpring) {
                model.showViewPicker()
            }
        }) {
            HStack(alignment: .center, spacing: 0) {
                AnytypeText(model.activeView.name, style: .subheading, color: .textPrimary)
                Spacer.fixedWidth(4)
                Image(asset: .arrowDown).foregroundColor(.textPrimary)
            }
        }
    }
}

struct SetHeaderSettings_Previews: PreviewProvider {
    static var previews: some View {
        SetHeaderSettings()
    }
}
