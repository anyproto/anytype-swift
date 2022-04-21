import SwiftUI
import AnytypeCore

struct UndoRedoView: View {
    let viewModel: UndoRedoViewModel

    var body: some View {
        HStack(spacing: 16) {
            ForEach(viewModel.buttonModels) { buttonModel in
                Button {
                    buttonModel.action()
                } label: {
                    ItemView(
                        image: buttonModel.image,
                        title: buttonModel.title
                    )
                }
            }
        }
        .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
    }
}

private struct ItemView: View {
    let image: UIImage
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Image(uiImage: image)
                .frame(height: 52)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .center
                )
                .background(Color.backgroundSelected)
                .cornerRadius(10.5)
            AnytypeText(title, style: .caption2Regular, color: .textSecondary)
        }
    }
}

struct UndoRedoView_Previews: PreviewProvider {
    static var previews: some View {
        UndoRedoView(viewModel: .init(objectId: AnytypeId(UUID().uuidString)!))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
