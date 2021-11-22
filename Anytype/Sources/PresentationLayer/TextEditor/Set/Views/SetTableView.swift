import SwiftUI

struct SetTableView: View {
    @Binding var yOffset: CGFloat
    @Binding var headerSize: CGSize
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var xOffset = CGFloat.zero
    @State private var initialOffset = CGFloat.zero
    
    var body: some View {
        GeometryReader { geo in
            OffsetAwareScrollView(
                axes: [.horizontal, .vertical],
                showsIndicators: false,
                offsetChanged: {
                    xOffset = $0.x
                    if -$0.y < (headerSize.height + 100) { yOffset = $0.y } // optimization
                }
            ) {
                ScrollViewReader { reader in
                    VStack(spacing: 0) {
                        Rectangle().foregroundColor(.clear).frame(height: headerSize.height)
                            .id("fakeHeaderId")
                        tableHeader
                        tableContent.onAppear {
                            reader.scrollTo("fakeHeaderId", anchor: UnitPoint.zero)
                        }
                        Spacer()
                    }
                  .frame(minWidth: geo.size.width, minHeight: geo.size.height)
            
                }
                .onAppear {
                    initialOffset = xOffset
                }
            }
        }
    }
    
    private var tableHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(model.colums, id: \.key) { name in
                    AnytypeText(name.value, style: .relation2Regular, color: .textSecondary)
                        .frame(width: 144)
                    
                    Rectangle()
                        .frame(width: 0.5, height: 18)
                        .foregroundColor(.grayscale30)
                }
            }
            .frame(height: 40)
            Divider()
        }
    }
    
    private var tableContent: some View {
        LazyVStack(alignment: .leading) {
            ForEach(model.rows) { row in
                SetTableViewRow(data: row, initialOffset: initialOffset, xOffset: xOffset)
            }
        }
    }
}

struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(yOffset: .constant(0), headerSize: .constant(.zero))
    }
}
