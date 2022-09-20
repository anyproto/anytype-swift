import SwiftUI
import BlocksModels

struct SetViewTypesPicker: View {
    @ObservedObject var viewModel: SetViewTypesPickerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            InlineNavigationBar {
                TitleView(title: Loc.SetViewTypesPicker.title)
            } rightButton: {
                if viewModel.hasActiveView {
                    settingsMenu
                }
            }
            content
            Spacer()
            button
            Spacer.fixedHeight(8)
        }
    }
    
    private var settingsMenu: some View {
        Menu {
            if viewModel.canDelete {
                deleteButton
            }
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
        ScrollView(.vertical, showsIndicators: false) {
            nameSection
            typesSection
        }
        .padding(.horizontal, 20)
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(11)
            AnytypeText(Loc.name, style: .caption1Regular, color: .textSecondary)
            Spacer.fixedHeight(6)
            
            TextField(
                viewModel.hasActiveView ?
                Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.untitled :
                Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.New.view,
                text: $viewModel.name
            )
                .foregroundColor(.textPrimary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
            Spacer.fixedHeight(10)
        }
        .divider(alignment: .leading)
    }

    
    private func sectionTitle(_ title: String) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            Spacer.fixedHeight(8)
        }
        .divider(alignment: .leading)
    }
    
    private var typesSection: some View {
        VStack(spacing: 0) {
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
            if configuration.isSelected && configuration.isSupported {
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

struct SetViewTypesPicker_Previews: PreviewProvider {
    static var previews: some View {
        SetViewTypesPicker(
            viewModel: SetViewTypesPickerViewModel(
                activeView: DataviewView.empty,
                canDelete: true,
                dataviewService: DataviewService(
                    objectId: "objectId",
                    prefilledFieldsBuilder: SetFilterPrefilledFieldsBuilder()
                )
            )
        )
    }
}
