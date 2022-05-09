import SwiftUI

struct NewRelationView: View {
    
    @ObservedObject private(set) var viewModel: NewRelationViewModel
    
    init(viewModel: NewRelationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "New relation".localized)
            content
        }
        .padding(.horizontal, 20)
    }

    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                nameSection
                formatSection
                restrictionsSection
                Spacer.fixedHeight(10)
                Spacer()
                button
            }
        }
    }
    
    private var nameSection: some View {
        NewRelationSectionView(
            title: "Relation name".localized,
            contentViewBuilder: {
                TextField("No name".localized, text: $viewModel.name)
                    .foregroundColor(.textPrimary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .heading))
            },
            onTap: nil,
            isArrowVisible: false
        )
    }
    
    private var formatSection: some View {
        NewRelationSectionView(
            title: "Relation type".localized,
            contentViewBuilder: {
                NewRelationFormatSectionView(model: viewModel.formatModel)
            },
            onTap: {
                viewModel.didTapFormatSection()
            },
            isArrowVisible: true
        )
    }
    
    private var restrictionsSection: some View {
        viewModel.objectTypesRestrictionModel.flatMap { model in
            NewRelationSectionView(
                title: "Limit object types".localized,
                contentViewBuilder: {
                    NewRelationRestrictionsSectionView(model: model)
                },
                onTap: {
                    viewModel.didTapTypesRestrictionSection()
                },
                isArrowVisible: true
            )
        }
    }
    
    private var button: some View {
        StandardButton(disabled: !viewModel.isCreateButtonActive, text: "Create".localized, style: .primary) {
            viewModel.didTapAddButton()
        }
        .padding(.vertical, 10)
    }
}
