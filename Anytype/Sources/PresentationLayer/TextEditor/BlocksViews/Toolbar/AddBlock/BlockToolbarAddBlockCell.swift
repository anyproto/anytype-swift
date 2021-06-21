import SwiftUI

struct BlockToolbarAddBlockCell: View {
    var viewModel: BlockToolbarAddBlockCellViewModel
    var view: some View {
        HStack {
            Image(viewModel.imageResource).renderingMode(.original)
            VStack(alignment: .leading) {
                AnytypeText(self.viewModel.title, style: .heading)
                    .foregroundColor(Color(UIColor.grayscale90))
                Spacer(minLength: 5)
                AnytypeText(self.viewModel.subtitle, style: .caption)
                    .foregroundColor(Color(UIColor(red: 0.422, green: 0.415, blue: 0.372, alpha: 1)))
            }
        }
    }
    var body: some View {
        Button(action: {
            self.viewModel.pressed()
        }) {
            self.view
        }
    }
}

extension BlockToolbarAddBlockCell {
    enum ButtonColorScheme {
        case selected
        func backgroundColor() -> UIColor {
            .init(red: 0.165, green: 0.656, blue: 0.933, alpha: 1)
        }
    }

    struct SelectedButtonStyle: ButtonStyle {
        var pressedColor: UIColor
        func makeBody(configuration: Configuration) -> some View {
            configuration.label.background(configuration.isPressed ? Color(self.pressedColor) : Color.clear)
                .frame(minWidth: 1.0, idealWidth: nil, maxWidth: nil)
        }
    }
}

