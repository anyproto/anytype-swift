import SwiftUI

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
            TitleView(title: viewModel.title)
            content
        }
        .padding(.horizontal, 20)
        .snackbar(toastBarData: $viewModel.toastData)
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
            button
        }
    }
    
    private var nameSection: some View {
        NewPropertySectionView(
            title: Loc.name,
            contentViewBuilder: {
                TextField(Loc.untitled, text: $viewModel.name)
                    .foregroundColor(.Text.primary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .heading))
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
                title: Loc.type,
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
                isArrowVisible: true
            )
        }
    }
    
    private var button: some View {
        StandardButton(viewModel.confirmButtonTitle, style: .primaryLarge) {
            viewModel.didTapAddButton()
            dismiss()
        }
        .disabled(!viewModel.isCreateButtonActive)
        .padding(.vertical, 10)
    }
}
