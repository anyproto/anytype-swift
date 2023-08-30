import SwiftUI

struct SetLayoutSettingsView: View {
    @StateObject var model: SetLayoutSettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(8)
            TitleView(title: Loc.layout)
            viewTypes
            Spacer.fixedHeight(8)
            settingsSection
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 20)
    }
    
    private var viewTypes: some View {
        LazyVGrid(
            columns: columns()
        ) {
            ForEach(model.types) {
                viewTypeContent($0)
            }
        }
    }
    
    private func viewTypeContent(_ configuration: SetViewTypeConfiguration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: configuration.icon)
            AnytypeText(
                configuration.name,
                style: configuration.isSelected ? .caption2Medium : .caption2Regular,
                color: configuration.isSelected ? .System.amber100 : .Text.secondary
            )
        }
        .frame(height: 106)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    configuration.isSelected ? Color.System.amber50 : Color.Text.secondary,
                    lineWidth: configuration.isSelected ? 2 : 0.5
                )
        )
        .onTapGesture {
            configuration.onTap()
        }
    }
    
    private func columns() -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 8, alignment: .topLeading),
            count: 3
        )
    }
    
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            ForEach(model.settings) { setting in
                Group {
                    switch setting {
                    case let .toggle(item):
                        toggleSettings(with: item)
                    case let .value(item):
                        valueSetting(with: item)
                    }
                }
                .if(model.settings.last != setting) {
                    $0.divider()
                }
            }
        }
    }
    
    private func valueSetting(with model: EditorSetViewSettingsValueItem) -> some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(model.title, style: .uxTitle2Regular, color: .Text.primary)
                Spacer()
                AnytypeText(model.value, style: .uxCalloutRegular, color: .Text.secondary)
                Spacer.fixedWidth(6)
                Image(asset: .X24.Arrow.right)
                    .foregroundColor(.Text.tertiary)
            }
        }
        .frame(height: 52)
    }
    
    private func toggleSettings(with model: EditorSetViewSettingsToggleItem) -> some View {
        AnytypeToggle(
            title: model.title,
            font: .uxTitle2Regular,
            isOn: model.isSelected
        ) {
            model.onChange($0)
        }
        .frame(height: 52)
    }
}
