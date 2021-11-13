import SwiftUI

struct SetTableView: View {
    @State private var xOffset = CGFloat.zero
    @State private var initialOffset = CGFloat.zero
    
    private let colums = SetDemoData.colums
    private let rows = SetDemoData.rows
    
    var body: some View {
        OffsetAwareScrollView(
            axes: .horizontal,
            showsIndicators: false,
            offsetChanged: { xOffset = $0.x }
        ) {
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
                ForEach(colums, id: \.self) { name in
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
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(rows, id: \.self) { row in
                    rowsView(row: row)
                }
            }
        }
    }
    
    private func rowsView(row: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText("🚀 " + row, style: .body, color: .grayscale90)
                .padding()
                .offset(x: initialOffset >= xOffset ? initialOffset - xOffset : 0, y: 0)
            
            HStack(spacing: 0) {
                ForEach(colums, id: \.self) { colum in
                    AnytypeText(row + colum, style: .relation2Regular, color: .textPrimary)
                        .frame(width: 144)
                    Rectangle()
                        .frame(width: 0.5, height: 18)
                        .foregroundColor(.grayscale30)
                }
            }
        }
    }
}

struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView()
    }
}
