import SwiftUI
import AnytypeCore

struct SetHeaderSettingsView: View {
    
    @StateObject var model: SetHeaderSettingsViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            viewButton
            Spacer()
            settingButton

            if !model.isActiveHeader || model.isActiveCreateButton {
                Spacer.fixedWidth(16)
                createView
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
    }
    
    @ViewBuilder
    private var createView: some View {
        compositeCreateButtons
    }
    
    private var settingButton: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            model.onSettingsTap()
        }) {
            Image(asset: .X24.customizeView)
                .foregroundColor(model.isActiveHeader ? .Button.active : .Button.inactive)
        }
        .disabled(!model.isActiveHeader)
    }
    
    private var compositeCreateButtons: some View {
        HStack(spacing: 0) {
            StandardButton(
                Loc.new,
                style: .primaryXSmall,
                corners: [.topLeft, .bottomLeft]
            ) {
                UISelectionFeedbackGenerator().selectionChanged()
                model.onCreateTap()
            }
            .disabled(!model.isActiveCreateButton)
            Rectangle()
                .fill(Color.clear)
                .frame(width: 1, height: 28)
                .background(Color.Additional.separator)
            StandardButton(.image(.X18.listArrow), style: .primaryXSmall, corners: [.topRight, .bottomRight]) {
                UISelectionFeedbackGenerator().selectionChanged()
                model.onSecondaryCreateTap()
            }
            .disabled(!model.isActiveCreateButton)
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
                    model.viewName.isNotEmpty ? model.viewName : Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.untitled,
                    style: .subheading
                )
                .foregroundColor(model.isActiveHeader ? .Text.primary : .Text.tertiary)
                Spacer.fixedWidth(4)
                Image(asset: .arrowDown)
                    .foregroundColor(model.isActiveHeader ? .Text.primary : .Text.tertiary)
            }
        }
        .disabled(!model.isActiveHeader)
    }
}

struct SetHeaderSettings_Previews: PreviewProvider {
    static var previews: some View {
        SetHeaderSettingsView(
            model: SetHeaderSettingsViewModel(
                setDocument: SetDocument(
                    document: DI.preview.serviceLocator.documentsProvider.document(objectId: "", forPreview: false),
                    inlineParameters: nil,
                    relationDetailsStorage: DI.preview.serviceLocator.relationDetailsStorage(),
                    objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider(),
                    accountParticipantsStorage: DI.preview.serviceLocator.accountParticipantStorage(),
                    permissionsBuilder: SetPermissionsBuilder()
                ),
                onViewTap: {},
                onSettingsTap: {},
                onCreateTap:{},
                onSecondaryCreateTap: {}
            )
        )
    }
}
