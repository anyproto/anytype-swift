import SwiftUI
import AnytypeCore

struct PropertyInfoView: View {
    
    @StateObject private var viewModel: PropertyInfoViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: PropertyInfoData, output: (any PropertyInfoModuleOutput)?) {
        let relationsInteractor = PropertiesInteractor(objectId: data.objectId, spaceId: data.spaceId)
        _viewModel = StateObject(wrappedValue: PropertyInfoViewModel(
            data: data,
            relationsInteractor: relationsInteractor,
            output: output
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: viewModel.title) {
                if viewModel.canShowMenu {
                    Button(action: {
                        viewModel.didTapMenuButton()
                    }) {
                        IconView(icon: .asset(.CustomIcons.ellipsisHorizontal))
                            .frame(width: 24, height: 24)
                    }
                }
            }
            content
        }
        .padding(.horizontal, 20)
        .snackbar(toastBarData: $viewModel.toastData)
        .actionSheet(isPresented: $viewModel.showMenuActions) {
            ActionSheet(
                title: Text(viewModel.name.isEmpty ? Loc.untitled : viewModel.name),
                buttons: [
                    .default(Text(Loc.duplicate)) {
                        viewModel.didTapDuplicate()
                    },
                    .destructive(Text(Loc.delete)) {
                        viewModel.didTapDelete()
                    },
                    .cancel()
                ]
            )
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                nameSection
                formatSection
                restrictionsSection
                Spacer.fixedHeight(10)
            }
            Spacer()
            
            if !viewModel.isReadOnly {
                button
            }
        }
    }
    
    private var nameSection: some View {
        NewPropertySectionView(
            title: Loc.name,
            contentViewBuilder: {
                TextField(Loc.untitled, text: $viewModel.name)
                    .foregroundColor(.Text.primary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                    .disabled(viewModel.isReadOnly)
            },
            onTap: nil,
            isArrowVisible: false
        )
    }
    
    private var formatSection: some View {
        if viewModel.mode.canEditRelationType {
            NewPropertySectionView(
                title: Loc.format,
                contentViewBuilder: {
                    NewPropertyFormatSectionView(model: viewModel.formatModel)
                },
                onTap: {
                    UIApplication.shared.hideKeyboard()
                    viewModel.didTapFormatSection()
                },
                isArrowVisible: true
            )
        } else {
            NewPropertySectionView(
                title: Loc.format,
                contentViewBuilder: {
                    NewPropertyFormatSectionView(model: viewModel.formatModel)
                },
                onTap: nil,
                isArrowVisible: false
            )
        }
    }
    
    private var restrictionsSection: some View {
        viewModel.objectTypesRestrictionModel.flatMap { model in
            NewPropertySectionView(
                title: Loc.limitObjectTypes,
                contentViewBuilder: {
                    NewPropertyRestrictionsSectionView(model: model)
                },
                onTap: {
                    UIApplication.shared.hideKeyboard()
                    viewModel.didTapTypesRestrictionSection()
                },
                isArrowVisible: !viewModel.isReadOnly
            )
            .disabled(viewModel.isReadOnly)
        }
    }
    
    private var button: some View {
        StandardButton(viewModel.confirmButtonTitle, style: .primaryLarge) {
            viewModel.didTapAddButton()
            dismiss()
        }
        .disabled(!viewModel.isSaveButtonActive)
        .padding(.vertical, 10)
    }
}
