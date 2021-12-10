import SwiftUI

struct SetTableView: View {
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    var headerMinimizedSize: CGSize

    @State private var initialOffset = CGPoint.zero

    @EnvironmentObject private var model: EditorSetViewModel

    var body: some View {
        SingleAxisGeometryReader { fullWidth in
            OffsetAwareScrollView(
                axes: [.horizontal, .vertical],
                showsIndicators: false,
                offsetChanged: { offset = $0 }
            ) {
                SetFullHeader()
                    .offset(x: xOffset, y: 0)
                    .background(FrameCatcher { tableHeaderSize = $0.size })
                LazyVStack(
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    Section(header: compoundHeader) {
                        tableContent
                    }
                }
                .frame(minWidth: fullWidth)
                .onAppear {
                    DispatchQueue.main.async {
                        // initial y offset is 0 for some reason
                        offset = CGPoint(x: offset.x, y: 0)
                        initialOffset = offset
                    }
                }
                .padding(.top, -headerMinimizedSize.height)
            }
        }
    }

    private var tableContent: some View {
        LazyVStack(alignment: .leading) {
            ForEach(model.rows) { row in
                SetTableViewRow(data: row, initialOffset: initialOffset.x, xOffset: offset.x)
            }
        }
    }

    private var xOffset: CGFloat {
        initialOffset.x >= offset.x ? initialOffset.x - offset.x : 0
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            Group {
                SetHeaderSettings()
                    .offset(x: xOffset, y: 0)
                    .environmentObject(model)
                SetTableViewHeader()
            }
            .background(Color.background)
        }
    }
}


struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero
        )
    }
}

