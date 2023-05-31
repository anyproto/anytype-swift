import SwiftUI
import Services

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
            Image(asset: .X24.more)
                .foregroundColor(.Button.active)
                .frame(width: 24, height: 24)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            viewModel.deleteView()
        }) {
            AnytypeText(
                Loc.SetViewTypesPicker.Settings.Delete.view,
                style: .uxCalloutRegular,
                color: .Text.primary
            )
        }
    }
    
    private var duplicateButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            viewModel.duplicateView()
        }) {
            AnytypeText(
                Loc.SetViewTypesPicker.Settings.Duplicate.view,
                style: .uxCalloutRegular,
                color: .Text.primary
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
            AnytypeText(Loc.name, style: .caption1Regular, color: .Text.secondary)
            Spacer.fixedHeight(6)
            
            TextField(
                viewModel.hasActiveView ?
                Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.untitled :
                Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.New.view,
                text: $viewModel.name
            )
                .foregroundColor(.Text.primary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
            Spacer.fixedHeight(10)
        }
        .divider(alignment: .leading)
    }

    
    private func sectionTitle(_ title: String) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(title, style: .caption1Regular, color: .Text.secondary)
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
        .divider()
    }
    
    private func viewTypeContent(_ configuration: SetViewTypeConfiguration) -> some View {
        HStack(spacing: 10) {
            Image(asset: configuration.icon)
                .renderingMode(.template)
                .foregroundColor(.Button.active)
            AnytypeText(
                configuration.name,
                style: .uxBodyRegular,
                color: .Text.primary
            )
            Spacer()
            if configuration.isSelected {
                Image(asset: .X24.tick)
                    .foregroundColor(.Button.button)
            }
        }
    }
    
    private var button: some View {
        StandardButton(Loc.done, style: .primaryLarge) {
            presentationMode.wrappedValue.dismiss()
            viewModel.buttonTapped()
        }
        .padding(.horizontal, 20)
    }
}

struct SetViewTypesPicker_Previews: PreviewProvider {
    static var previews: some View {
        SetViewTypesPicker(
            viewModel: SetViewTypesPickerViewModel(
                setDocument: SetDocument(
                    document: BaseDocument(objectId: "blockId"),
                    blockId: nil,
                    targetObjectID: nil,
                    relationDetailsStorage: DI.preview.serviceLocator.relationDetailsStorage()
                ),
                activeView: DataviewView.empty,
                dataviewService: DataviewService(
                    objectId: "objectId",
                    blockId: "blockId",
                    prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
                ),
                relationDetailsStorage: DI.preview.serviceLocator.relationDetailsStorage()
            )
        )
    }
}
