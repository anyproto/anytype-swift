import SwiftUI

struct SetFiltersSearchView: View {
    @EnvironmentObject var viewModel: SetFiltersSearchViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        headerView
        viewModel.makeSearchView()
        Spacer()
    }
    
    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.backgroundSelected)
                Image.createImage(viewModel.headerConfiguration.iconName)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(viewModel.headerConfiguration.title, style: .uxTitle2Medium, color: .textPrimary)
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        AnytypeText(viewModel.headerConfiguration.condition, style: .relation1Regular, color: .textSecondary)
                        Image.arrowDown.foregroundColor(.textSecondary).padding(.top, 2)
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
}
