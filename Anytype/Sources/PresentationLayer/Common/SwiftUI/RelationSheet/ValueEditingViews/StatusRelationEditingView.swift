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
        ForEach(viewModel.allStatuses) { status in
            StatusRelationRowView(
                status: status,
                isSelected: status == viewModel.selectedStatus
            )
        }
    }
}

struct StatusRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationEditingView(
            viewModel: StatusRelationEditingViewModel(
                relationKey: "",
                relationOptions: [],
                selectedStatus: nil,
                detailsService: DetailsService(objectId: "")
            )
        )
    }
}
