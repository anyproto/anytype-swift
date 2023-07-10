import SwiftUI
import AnytypeCore

struct SetHeaderSettingsView: View {
    
    let model: SetHeaderSettingsViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            viewButton
            Spacer()
            settingButton

            Spacer.fixedWidth(16)
            if FeatureFlags.setTemplateSelection {
                compositeCreateButtons
            } else {
                createObjectButton
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
    }
    
    private var settingButton: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            model.onSettingsTap()
        }) {
            Image(asset: .X24.customizeView)
                .foregroundColor(model.isActive ? .Button.active : .Button.inactive)
        }
        .disabled(!model.isActive)
    }
    
    private var createObjectButton: some View {
        StandardButton(.text(Loc.new), style: .primaryXSmall) {
            UISelectionFeedbackGenerator().selectionChanged()
            model.onCreateTap()
        }
        .disabled(!model.isActive)
    }
    
    private var compositeCreateButtons: some View {
        HStack(spacing: 0) {
            StandardButton(
                .text(Loc.new),
                style: .primaryXSmall,
                corners: [.topLeft, .bottomLeft]
            ) {
                UISelectionFeedbackGenerator().selectionChanged()
                model.onCreateTap()
            }
            .disabled(!model.isActive)
            Rectangle()
                .fill(Color.Stroke.primary)
                .frame(width: 1, height: 28)
            StandardButton(.image(.X18.listArrow), style: .primaryXSmall, corners: [.topRight, .bottomRight]) {
                UISelectionFeedbackGenerator().selectionChanged()
                model.onSecondaryCreateTap()
            }
            .disabled(!model.isActive)
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
                onCreateTap:{},
                onSecondaryCreateTap: {}
            )
        )
    }
}
