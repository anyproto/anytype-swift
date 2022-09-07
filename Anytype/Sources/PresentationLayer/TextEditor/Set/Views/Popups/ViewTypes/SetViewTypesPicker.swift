import SwiftUI

struct SetViewTypesPicker: View {
    @ObservedObject var viewModel: SetViewTypesPickerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            InlineNavigationBar {
                TitleView(title: Loc.SetViewTypesPicker.title)
            } rightButton: {
                settingsMenu
            }
            content
            Spacer()
            button
        }
    }
    
    private var settingsMenu: some View {
        Menu {
            deleteButton
            duplicateButton
        } label: {
            Image(asset: .more)
                .foregroundColor(.buttonActive)
                .frame(width: 24, height: 24)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            viewModel.deleteView {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            AnytypeText(
                Loc.SetViewTypesPicker.Settings.Delete.view,
                style: .uxCalloutRegular,
                color: .textPrimary
            )
        }
    }
    
    private var duplicateButton: some View {
        Button(action: {
            viewModel.duplicateView {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            AnytypeText(
                Loc.SetViewTypesPicker.Settings.Duplicate.view,
                style: .uxCalloutRegular,
                color: .textPrimary
            )
        }
    }
    
    private var content: some View {
        typesSection
            .padding(.horizontal, 20)
    }
    
    private func sectionTitle(_ title: String) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(11)
            AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            Spacer.fixedHeight(8)
        }
        .divider(alignment: .leading)
    }
    
    private var typesSection: some View {
        Group {
            sectionTitle(Loc.SetViewTypesPicker.Section.Types.title)
            ForEach(viewModel.types) {
                viewType($0)
            }
        }
    }
    
    private func viewType(_ configuration: SetViewTypeConfiguration) -> some View {
        Button {
            configuration.onTap()
        } label: {
            viewTypeContent(configuration)
        }
        .frame(height: 52, alignment: .leading)
        .disabled(!configuration.isSupported)
        .divider()
    }
    
    private func viewTypeContent(_ configuration: SetViewTypeConfiguration) -> some View {
        HStack(spacing: 10) {
            Image(asset: configuration.icon)
                .renderingMode(.template)
                .foregroundColor(
                    configuration.isSupported ? .buttonActive : .buttonInactive
                )
            AnytypeText(
                configuration.name,
                style: .uxBodyRegular,
                color: configuration.isSupported ? .textPrimary : .textTertiary
            )
            Spacer()
            if !configuration.isSupported {
                AnytypeText(Loc.soon, style: .caption1Regular, color: .textTertiary)
            }
            if configuration.isSelected {
                Image(asset: .optionChecked)
                    .foregroundColor(.buttonSelected)
            }
        }
    }
    
    private var button: some View {
        StandardButton(disabled: false, text: Loc.done, style: .primary) {
            viewModel.buttonTapped() {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding(.horizontal, 20)
    }
}
