import SwiftUI

struct DateRelationDetailsView: View {
    
    @ObservedObject var viewModel: DateRelationDetailsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: viewModel.title)
            valueList
            Spacer()
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
    }
    
    private var valueList: some View {
        ForEach(viewModel.values, id: \.self) { value in
            DateRelationDetailsRowView(
                value: value,
                isSelected: value == viewModel.selectedValue,
                date: $viewModel.date
            ) {
                viewModel.selectedValue = value
            }
        }
    }
}

struct DateRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        DateRelationDetailsView(
            viewModel: DateRelationDetailsViewModel(
                value: nil,
                relation: .date(Relation.Date(key: "", name: "name", isFeatured: false, isEditable: false, isBundled: false, value: nil)),
                service: RelationsService(objectId: "")
            )
        )
    }
}
