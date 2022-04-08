import SwiftUI

struct TwoStandardButtonsView: View {
    let leftButtonData: StandardButtonModel
    let rightButtonData: StandardButtonModel

    var body: some View {
        HStack(spacing: 8) {
            StandardButton(model: leftButtonData)
            StandardButton(model: rightButtonData)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct TwoStandardButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TwoStandardButtonsView(
            leftButtonData: .init(
                text: "Cancel",
                style: .secondary,
                action: {}
            ),
            rightButtonData:
                    .init(
                        text: "Move",
                        style: .primary,
                        action: {}
                    )
        )
            .previewLayout(.fixed(width: 340, height: 68))
    }
}
