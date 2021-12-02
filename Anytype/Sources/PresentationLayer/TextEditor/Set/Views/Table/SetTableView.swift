import SwiftUI

struct SetTableView: View {
    @Binding var offset: CGPoint
    @Binding var headerSize: CGSize
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var initialOffset = CGPoint.zero
    
    var body: some View {
        GeometryReader { geo in
            OffsetAwareScrollView(
                axes: [.horizontal, .vertical],
                showsIndicators: false,
                offsetChanged: {
                    offset.x = $0.x
                    if -$0.y < (headerSize.height + 100) { offset.y = $0.y } // optimization
                }
            ) {
                ScrollViewReader { reader in
                    VStack(spacing: 0) {
                        Rectangle().foregroundColor(.clear).frame(height: headerSize.height)
                            .id("fakeHeaderId")
                        Divider()
                        SetTableViewHeader()
                        tableContent.onAppear {
                            reader.scrollTo("fakeHeaderId", anchor: UnitPoint.zero)
                        }
                        Spacer()
                    }
                  .frame(minWidth: geo.size.width, minHeight: geo.size.height)
            
                }
                .onAppear {
                    initialOffset = offset
                }
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
}

struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(offset: .constant(.zero), headerSize: .constant(.zero))
    }
}
