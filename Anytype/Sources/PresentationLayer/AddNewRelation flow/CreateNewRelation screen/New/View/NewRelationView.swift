import SwiftUI

struct NewRelationView: View {
    
    @ObservedObject private(set) var viewModel: NewRelationViewModel
        
    init(viewModel: NewRelationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: "New relation".localized)
            nameSection
            formatSection
            restrictionsSection
            Spacer.fixedHeight(10)
            button
        }
        .padding(.horizontal, 20)
    }
    
    private var nameSection: some View {
        NewRelationSectionView(
            title: "Name".localized,
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
        NewRelationFormatSectionView(model: viewModel.formatModel) {
            viewModel.didTapFormatSection()
        }
    }
    
    private var restrictionsSection: some View {
        viewModel.objectTypesRestrictionModel.flatMap {
            NewRelationRestrictionsSectionView(model: $0) {
                viewModel.didTapTypesRestrictionSection()
            }
        }
    }
    
    private var button: some View {
        StandardButton(disabled: !viewModel.isCreateButtonActive, text: "Сreate".localized, style: .primary) {
            viewModel.didTapAddButton()
        }
        .padding(.vertical, 10)
    }
}
