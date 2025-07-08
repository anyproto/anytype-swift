import SwiftUI

struct SetLayoutSettingsView: View {
    @StateObject private var model: SetLayoutSettingsViewModel

    init(setDocument: some SetDocumentProtocol, viewId: String, output: (any SetLayoutSettingsCoordinatorOutput)?) {
        _model = StateObject(wrappedValue: SetLayoutSettingsViewModel(
            setDocument: setDocument,
            viewId: viewId,
            output: output
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.layout)
            ScrollView(.vertical, showsIndicators: false) {
                content
            }
        }
        .background(Color.Background.secondary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(2)
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
                style: configuration.isSelected ? .caption2Medium : .caption2Regular
            )
            .foregroundColor(configuration.isSelected ? .System.amber100 : .Text.secondary)
        }
        .frame(height: 96)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    configuration.isSelected ? Color.Control.accent50 : Color.Shape.primary,
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
                    case let .context(item):
                        contextMenu(with: item)
                    }
                }
                .if(model.settings.last != setting) {
                    $0.divider()
                }
            }
        }
    }
    
    private func valueSetting(with model: SetViewSettingsValueItem) -> some View {
        Button {
            model.onTap()
        } label: {
            valueSettingContent(title: model.title, value: model.value, contextual: false)
        }
        .frame(height: 52)
    }
    
    private func toggleSettings(with model: SetViewSettingsToggleItem) -> some View {
        AnytypeToggle(
            title: model.title,
            font: .uxBodyRegular,
            isOn: model.isSelected
        ) {
            model.onChange($0)
        }
        .frame(height: 52)
    }
    
    private func contextMenu(with model: SetViewSettingsContextItem) -> some View {
        Menu {
            VStack(spacing: 0) {
                ForEach(model.options) { option in
                    Button {
                        option.onTap()
                    } label: {
                        AnytypeText(option.id, style: .uxBodyRegular)
                            .foregroundColor(.Text.primary)
                    }
                }
            }
        } label: {
            valueSettingContent(title: model.title, value: model.value, contextual: true)
        }
        .frame(height: 52)
    }
    
    private func valueSettingContent(title: String, value: String, contextual: Bool) -> some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
            Spacer()
            AnytypeText(value, style: .uxBodyRegular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedWidth(6)
            Image(asset: contextual ? .X18.Disclosure.down : .X18.Disclosure.right)
                .foregroundColor(.Control.active)
        }
    }
}
