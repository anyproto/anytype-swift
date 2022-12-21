import SwiftUI

struct NewRelationView: View {
    
    @ObservedObject private(set) var viewModel: NewRelationViewModel
    
    init(viewModel: NewRelationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.newRelation)
            content
        }
        .padding(.horizontal, 20)
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
                TextField(Loc.noName, text: $viewModel.name)
                    .foregroundColor(.TextNew.primary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .heading))
            },
            onTap: nil,
            isArrowVisible: false
        )
    }
    
    private var formatSection: some View {
        NewRelationSectionView(
            title: Loc.type,
            contentViewBuilder: {
                NewRelationFormatSectionView(model: viewModel.formatModel)
            },
            onTap: {
                UIApplication.shared.hideKeyboard()
                viewModel.didTapFormatSection()
            },
            isArrowVisible: true
        )
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
        StandardButton(disabled: !viewModel.isCreateButtonActive, text: Loc.create, style: .primary) {
            viewModel.didTapAddButton()
        }
        .padding(.vertical, 10)
    }
}
