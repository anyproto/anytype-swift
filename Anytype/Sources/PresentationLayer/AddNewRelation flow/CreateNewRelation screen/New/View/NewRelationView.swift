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
        NewRelationFormatSectionView(format: viewModel.format) {
            viewModel.didTapFormatSection()
        }
    }
    
    private var restrictionsSection: some View {
        viewModel.objectTypeRestrictions.flatMap {
            NewRelationRestrictionsSectionView(model: $0) {
                viewModel.didTapRestrictionsSection()
            }
        }
    }
}

//struct NewRelationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewRelationView(viewModel: NewRelationViewModel(name: "name"))
//    }
//}
