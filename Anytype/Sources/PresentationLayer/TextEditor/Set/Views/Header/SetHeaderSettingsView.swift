import SwiftUI
import AnytypeCore

struct SetHeaderSettingsView: View {
    private let settingsHeight: CGFloat = 56
    
    @ObservedObject var model: SetHeaderSettingsViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            viewButton
            Spacer()
            settingButton

            Spacer.fixedWidth(16)
            createObjectButton
        }
        .padding(.horizontal, 20)
        .frame(height: settingsHeight)
    }
    
    private var settingButton: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            model.onSettingsTap()
        }) {
            Image(asset: .setSettings)
                .foregroundColor(model.isActive ? .Button.active : .Button.inactive)
        }
        .disabled(!model.isActive)
    }
    
    private var createObjectButton: some View {
        SmallButton(
            icon: .plusWhite12,
            text: Loc.new,
            isActive: model.isActive
        ) {
            UISelectionFeedbackGenerator().selectionChanged()
            model.onCreateTap()
        }
    }
    
    private var viewButton: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.fastSpring) {
                model.onViewTap()
            }
        }) {
            HStack(alignment: .center, spacing: 0) {
                AnytypeText(
                    model.viewName,
                    style: .subheading,
                    color: model.isActive ? .Text.primary : .Text.tertiary
                )
                Spacer.fixedWidth(4)
                Image(asset: .arrowDown)
                    .foregroundColor(model.isActive ? .Text.primary : .Text.tertiary)
            }
        }
        .disabled(!model.isActive)
    }
}

struct SetHeaderSettings_Previews: PreviewProvider {
    static var previews: some View {
        SetHeaderSettingsView(
            model: SetHeaderSettingsViewModel(
                setDocument: SetDocument(
                    document: BaseDocument(objectId: "blockId"),
                    blockId: nil,
                    targetObjectID: nil,
                    relationDetailsStorage: DI.preview.serviceLocator.relationDetailsStorage()
                ),
                isActive: true,
                onViewTap: {},
                onSettingsTap: {},
                onCreateTap:{}
            )
        )
    }
}
