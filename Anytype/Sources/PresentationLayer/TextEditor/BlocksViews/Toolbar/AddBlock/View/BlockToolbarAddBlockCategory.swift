import SwiftUI

struct BlockToolbarAddBlockCategory: View {
    var viewModel: BlockToolbarAddBlockCategoryViewModel
    var cells: [BlockToolbarAddBlockCellViewModel]
    var header: some View {
        HStack {
            AnytypeText(self.viewModel.uppercasedTitle, style: .headline)
                .foregroundColor(Color(UIColor(red: 0.675, green: 0.663, blue: 0.588, alpha: 1)))
                .padding()
            Spacer()
        }.background(Color.background).listRowInsets(.init(.init()))
    }
    var body: some View {
        Section(header: self.header) {
            ForEach(self.cells) { cell in
                BlockToolbarAddBlockCell(viewModel: cell)
            }
        }
    }
}
