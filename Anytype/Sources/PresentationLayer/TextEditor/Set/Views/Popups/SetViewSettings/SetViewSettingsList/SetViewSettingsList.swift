import SwiftUI

struct SetViewSettingsList: View {
    @StateObject var model: SetViewSettingsListModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(
                title: model.mode.title,
                rightButton: {
                    settingsMenu
                }
            )
            
            content
        }
        .background(Color.Background.secondary)
        .frame(maxHeight: 358)
    }
    
    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                viewName
                
                Spacer.fixedHeight(12)
                
                settings
                
                Spacer.fixedHeight(8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 1)
        }
        .bounceBehaviorBasedOnSize()
    }
    
    private var viewName: some View {
        VStack(alignment: .leading, spacing: 0) {
            viewNameContent
                .padding(.horizontal, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                isFocused ? Color.System.amber50 : Color.Shape.primary,
                lineWidth: isFocused ? 2 : 1
            )
        )
    }
    
    @ViewBuilder
    private var viewNameContent: some View {
        Spacer.fixedHeight(10)
        
        AnytypeText(Loc.name, style: .caption1Medium, color: .Text.secondary)
        
        Spacer.fixedHeight(2)
        
        TextField(
            model.mode.placeholder,
            text: $model.name
        )
        .foregroundColor(.Text.primary)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxTitle1Semibold))
        .focused($isFocused)
        .task {
            isFocused = model.shouldSetupFocus()
        }
        
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
                AnytypeText(
                    setting.title,
                    style: .uxBodyRegular,
                    color: .Text.primary
                )
                
                Spacer()
                
                value(for: setting)
                
                Spacer.fixedWidth(6)
                
                Image(asset: .X18.Disclosure.right)
                    .foregroundColor(.Button.active)
            }
        }
        .frame(height: 52, alignment: .leading)
        .if(!setting.isLast) {
            $0.divider()
        }
    }
    
    private func value(for setting: SetViewSettings) -> some View {
        let text = model.valueForSetting(setting)
        return AnytypeText(
            text,
            style: .uxBodyRegular,
            color: setting.isPlaceholder(text) ? .Text.tertiary : .Text.secondary
        )
        .lineLimit(1)
    }
    
    private var settingsMenu: some View {
        Menu {
            duplicateButton
            if model.canBeDeleted {
                deleteButton
            }
        } label: {
            Image(asset: .X24.more)
                .foregroundColor(.Button.active)
                .frame(width: 24, height: 24)
        }
        .fixMenuOrder()
    }
    
    private var deleteButton: some View {
        Button(Loc.SetViewTypesPicker.Settings.Delete.view, role: .destructive) {
            presentationMode.dismiss()
            model.deleteView()
        }
        .background(Color.Background.secondary)
    }
    
    private var duplicateButton: some View {
        Button(Loc.SetViewTypesPicker.Settings.Duplicate.view) {
            presentationMode.dismiss()
            model.duplicateView()
        }
        .background(Color.Background.secondary)
    }
}
