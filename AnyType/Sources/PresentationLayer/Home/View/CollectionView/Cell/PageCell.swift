import SwiftUI


// figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=4061%3A0
struct PageCell: View {
    var cellData: PageCellData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                icon
                iconSpacer
                Text(cellData.title).anyTypeFont(.captionMedium)
                textSpacer
                Text(cellData.type).anyTypeFont(.footnote).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16))
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var icon: some View {
        switch cellData.icon {
        case let .emoji(emoji):
            return Text(emoji)
                .font(.system(size: UIFontMetrics.default.scaledValue(for: 48)))
                .eraseToAnyView()
        case .pic:
            return Text("V") // TODO
                .font(.system(size: UIFontMetrics.default.scaledValue(for: 48)))
                .eraseToAnyView()
        case .none:
            return EmptyView().eraseToAnyView()
        }
    }
    
    private var iconSpacer: some View {
        switch cellData.icon {
        case .emoji, .pic:
            return Spacer().eraseToAnyView()
        case .none:
            return EmptyView().eraseToAnyView()
        }
    }
    
    private var textSpacer: some View {
        switch cellData.icon {
        case .none:
            return Spacer().eraseToAnyView()
        case .emoji, .pic:
            return EmptyView().eraseToAnyView()
        }
    }
}

struct PageCell_Previews: PreviewProvider {
    static let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    static let data = [
        PageCellData(
            icon: .emoji("📘"),
            title: "Ubik",
            type: "Book"
        ),
        PageCellData(
            icon: .none,
            title: "The president’s American Family Plan, which remains in flux, does not currently include",
            type: "Page"
        ),
        PageCellData(
            icon: .none,
            title: "GridItem",
            type: "Component"
        ),
        PageCellData(
            icon: .emoji("📘"),
            title: "Ubik",
            type: "Book"
        ),
        PageCellData(
            icon: .pic("picpath"),
            title: "Neo",
            type: "Character"
        )
    ]
    
    static var previews: some View {
        ScrollView() {
            LazyVGrid(columns: columns) {
                ForEach(data) { data in
                    PageCell(cellData: data)
                }
            }
            .padding()
        }
        .background(Color.orange.ignoresSafeArea())
    }
}
