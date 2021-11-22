import SwiftUI

struct SetTableView: View {
    @Binding var yOffset: CGFloat
    @Binding var headerSize: CGSize
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var xOffset = CGFloat.zero
    @State private var initialOffset = CGFloat.zero
    
    private let rows = SetDemoData.rows
    
    var body: some View {
        OffsetAwareScrollView(
            axes: [.horizontal, .vertical],
            showsIndicators: false,
            offsetChanged: {
                xOffset = $0.x
                if -$0.y < (headerSize.height + 100) { yOffset = $0.y } // optimization
            }
        ) {
            Rectangle().foregroundColor(.clear).frame(height: headerSize.height)
            tableHeader
            tableContent
        }
        .onAppear {
            initialOffset = xOffset
        }
    }
    
    private var tableHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(model.colums, id: \.self) { name in
                    AnytypeText(name, style: .relation2Regular, color: .textSecondary)
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
            ForEach(rows, id: \.self) { row in
                rowsView(row: row)
            }
        }
    }
    
    private func rowsView(row: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(18)
            
            AnytypeText("🚀 " + row, style: .body, color: .grayscale90)
                .padding(.horizontal, 16)
                .offset(x: initialOffset >= xOffset ? initialOffset - xOffset : 0, y: 0)
            Spacer.fixedHeight(18)
            HStack(spacing: 0) {
                ForEach(model.colums, id: \.self) { colum in
                    AnytypeText(row + colum, style: .relation2Regular, color: .textPrimary)
                        .frame(width: 144)
                    Rectangle()
                        .frame(width: 0.5, height: 18)
                        .foregroundColor(.grayscale30)
                }
            }
            
            Spacer.fixedHeight(12)
            Divider()
        }
        .frame(minWidth: 500)
    }
}

struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(yOffset: .constant(0), headerSize: .constant(.zero))
    }
}
