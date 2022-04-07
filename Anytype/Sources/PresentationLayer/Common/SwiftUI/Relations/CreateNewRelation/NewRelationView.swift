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
            nameSection
            formatSection
        }
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
}

struct NewRelationView_Previews: PreviewProvider {
    static var previews: some View {
        NewRelationView(viewModel: NewRelationViewModel(name: "name"))
    }
}
