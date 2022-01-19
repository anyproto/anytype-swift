import SwiftUI

struct DateRelationDetailsView: View {
    
    @ObservedObject var viewModel: DateRelationDetailsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(viewModel.relationName, style: .uxTitle1Semibold, color: .textPrimary)
                .frame(height: 48, alignment: .center)
            valueList
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
                relationKey: "",
                relationName: "",
                value: nil,
                service: RelationsService(objectId: "")
            )
        )
    }
}
