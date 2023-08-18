import SwiftUI

struct SetViewSettingsList: View {
    @StateObject var model: SetViewSettingsListModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(
                title: Loc.SetViewTypesPicker.title,
                rightButton: {
                    settingsMenu
                }
            )
            
            viewName
            
            Spacer.fixedHeight(12)
            
            settings
            
            Spacer.fixedHeight(8)
        }
        .padding(.horizontal, 20)
    }
    
    private var viewName: some View {
        VStack(alignment: .leading, spacing: 0) {
            viewNameContent
                .padding(.horizontal, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Color.Stroke.primary, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var viewNameContent: some View {
        Spacer.fixedHeight(10)
        
        AnytypeText(Loc.name, style: .caption1Medium, color: .Text.secondary)
        
        Spacer.fixedHeight(2)
        
        TextField(
            Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.New.view,
            text: $model.name
        )
        .foregroundColor(.Text.primary)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxTitle1Semibold))
        
        Spacer.fixedHeight(10)
    }
    
    private var settings: some View {
        ForEach(model.settings, id: \.self) { setting in
            row(for: setting)
        }
    }
    
    private func row(for setting: SetViewSettings) -> some View {
        Button {
            model.onSettingTap(setting)
        } label: {
            HStack(spacing: 0) {
                AnytypeText(setting.title, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                AnytypeText(setting.placeholder, style: .uxCalloutRegular, color: .Text.tertiary)
                    .lineLimit(1)
                Spacer.fixedWidth(6)
                Image(asset: .X24.Arrow.right)
                    .foregroundColor(.Text.tertiary)
            }
        }
        .frame(height: 52, alignment: .leading)
        .if(!setting.isLast) {
            $0.divider()
        }
    }
    
    private var settingsMenu: some View {
        Menu {
            deleteButton
            duplicateButton
        } label: {
            Image(asset: .X24.more)
                .foregroundColor(.Button.active)
                .frame(width: 24, height: 24)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            presentationMode.dismiss()
            model.deleteView()
        }) {
            AnytypeText(
                Loc.SetViewTypesPicker.Settings.Delete.view,
                style: .uxCalloutRegular,
                color: .System.red
            )
        }
    }
    
    private var duplicateButton: some View {
        Button(action: {
            presentationMode.dismiss()
            model.duplicateView()
        }) {
            AnytypeText(
                Loc.SetViewTypesPicker.Settings.Duplicate.view,
                style: .uxCalloutRegular,
                color: .Text.primary
            )
        }
    }
}
