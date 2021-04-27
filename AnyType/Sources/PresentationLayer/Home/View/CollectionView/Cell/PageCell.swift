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
        case let .image(image):
            if let image = image {
                return Image(uiImage: image).resizable()
                .frame(width: 48, height: 48)
                .cornerRadius(16)
                .eraseToAnyView()
            } else {
                return EmptyView().eraseToAnyView()
            }
        case .none:
            return EmptyView().eraseToAnyView()
        }
    }
    
    private var iconSpacer: some View {
        switch cellData.icon {
        case .emoji, .image:
            return Spacer().eraseToAnyView()
        case .none:
            return EmptyView().eraseToAnyView()
        }
    }
    
    private var textSpacer: some View {
        switch cellData.icon {
        case .none:
            return Spacer().eraseToAnyView()
        case .emoji, .image:
            return EmptyView().eraseToAnyView()
        }
    }
}

struct PageCell_Previews: PreviewProvider {
    static let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    static var previews: some View {
        ScrollView() {
            LazyVGrid(columns: columns) {
                ForEach(PageCellDataMock.data) { data in
                    PageCell(cellData: data)
                }
            }
            .padding()
        }
        .background(Color.orange.ignoresSafeArea())
    }
}
