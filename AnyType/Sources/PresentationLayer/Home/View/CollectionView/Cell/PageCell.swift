import SwiftUI


// figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=4061%3A0
struct PageCell: View {
    var cellData: PageCellData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                icon
                iconSpacer
                AnytypeText(cellData.title, style: .captionMedium).foregroundColor(.textPrimary)
                textSpacer
                AnytypeText(cellData.type, style: .footnote).foregroundColor(.textSecondary)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16))
        .background(Color.background)
        .cornerRadius(16)
    }
    
    private var icon: some View {
        Group {
            switch cellData.icon {
            case let .emoji(emoji):
                AnytypeText(emoji, name: .inter, size: 48, weight: .regular)
            case let .imageId(imageid):
                AsyncImage(imageId: imageid, parameters: ImageParameters(width: .thumbnail))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .cornerRadius(10)
            case .none:
                EmptyView()
            }
        }
    }
    
    private var iconSpacer: some View {
        Group {
            if cellData.icon != nil {
                Spacer()
            } else {
                EmptyView()
            }
        }
    }
    
    private var textSpacer: some View {
        Group {
            if cellData.icon == nil {
                Spacer()
            } else {
                EmptyView()
            }
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
