import SwiftUI

struct SetMinimizedHeader: View {
    var headerSize: CGSize
    var tableViewOffset: CGPoint
    @Binding var headerMinimizedSize: CGSize

    @EnvironmentObject private var model: EditorSetViewModel

    private let minimizedHeaderHeight: CGFloat = 92

    var body: some View {
        VStack {
            header
            Spacer()
        }
    }

    private var header: some View {
        SingleAxisGeometryReader { width in
            VStack {
                Spacer.fixedHeight(44)
                HStack {
                    if let icon = model.details.objectIconImage {
                        SwiftUIObjectIconImageView(iconImage: icon, usecase: .openedObjectNavigationBar)
                            .frame(width: 18, height: 18)
                        Spacer.fixedWidth(8)
                    }
                    AnytypeText(model.details.title, style: .body, color: .textPrimary)
                        .lineLimit(1)
                }
                .padding(.horizontal)
            }
            .frame(width: width, height: minimizedHeaderHeight)
            .background(Color.backgroundPrimary)
            .opacity(headerOpacity)
            .readSize { headerMinimizedSize = $0 }
        }
    }

    private var headerOpacity: Double {
        guard tableViewOffset.y < 0 else { return 0 }

        let startingOpacityHeight = headerSize.height - minimizedHeaderHeight
        return abs(tableViewOffset.y) / startingOpacityHeight
    }
}


struct SetMinimizedHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetMinimizedHeader(
            headerSize: .init(width: 100, height: 200),
            tableViewOffset: .zero,
            headerMinimizedSize: .constant(.zero)
        )
    }
}
