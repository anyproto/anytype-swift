import SwiftUI

struct StatusSearchRowView: View {
    
    let viewModel: StatusSearchRowViewModel
    let onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            label
        }
        .divider()
        .padding(.horizontal, 20)
    }
    
    private var label: some View {
        HStack(spacing: 0) {
            AnytypeText(viewModel.text, style: .relation1Regular, color: viewModel.color.suColor)
            Spacer()
        }
        .frame(height: 48)
    }
    
}
//
//struct StatusSearchRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusSearchRowView()
//    }
//}
