import SwiftUI

struct StatusRelationEditingView: View {
    
    @ObservedObject var viewModel: StatusRelationEditingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            valueList
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
    }
    
    private var valueList: some View {
        ForEach(viewModel.values) { value in
            StatusRelationRowView(
                status: value,
                isSelected: value == viewModel.selectedValue
            )
        }
    }
}

struct StatusRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationEditingView(
            viewModel: StatusRelationEditingViewModel(
                service: DetailsService(objectId: ""),
                key: "",
                allValues: [],
                value: nil
            )
        )
    }
}
