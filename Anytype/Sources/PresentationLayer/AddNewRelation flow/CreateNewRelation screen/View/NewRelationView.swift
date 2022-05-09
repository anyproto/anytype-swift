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
        VStack(alignment: .leading, spacing: 4) {
            sectionTitle("Relation name".localized)
            
            TextField("No name".localized, text: $viewModel.name)
                .foregroundColor(.textPrimary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
        }
        .frame(height: 68)
        .divider()
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
    
    private func sectionTitle(_ title: String) -> some View {
        AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            .lineLimit(1)
    }
    
    private var button: some View {
        StandardButton(disabled: !viewModel.isCreateButtonActive, text: "Create".localized, style: .primary) {
            viewModel.didTapAddButton()
        }
        .padding(.vertical, 10)
    }
}
