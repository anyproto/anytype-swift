import SwiftUI

struct RelationInfoView: View {
    
    @StateObject private var viewModel: RelationInfoViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: RelationInfoData, output: (any RelationInfoModuleOutput)?) {
        let relationsInteractor = RelationsInteractor(objectId: data.objectId, spaceId: data.spaceId)
        _viewModel = StateObject(wrappedValue: RelationInfoViewModel(
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
        NewRelationSectionView(
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
            NewRelationSectionView(
                title: Loc.format,
                contentViewBuilder: {
                    NewRelationFormatSectionView(model: viewModel.formatModel)
                },
                onTap: {
                    UIApplication.shared.hideKeyboard()
                    viewModel.didTapFormatSection()
                },
                isArrowVisible: true
            )
        } else {
            NewRelationSectionView(
                title: Loc.type,
                contentViewBuilder: {
                    NewRelationFormatSectionView(model: viewModel.formatModel)
                },
                onTap: nil,
                isArrowVisible: false
            )
        }
    }
    
    private var restrictionsSection: some View {
        viewModel.objectTypesRestrictionModel.flatMap { model in
            NewRelationSectionView(
                title: Loc.limitObjectTypes,
                contentViewBuilder: {
                    NewRelationRestrictionsSectionView(model: model)
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
