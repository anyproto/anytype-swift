import SwiftUI


// figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=4061%3A0
struct PageCell: View {
    var cellData: PageCellData
    
    private var isRedacted: Bool {
        cellData.isLoading
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                icon
                iconSpacer
                title
                textSpacer
                type
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16))
        .background(Color.background)
        .cornerRadius(16)
        .redacted(reason: isRedacted ? .placeholder : [])
    }
    
    private var title: some View {
        var title = cellData.title.isEmpty ? "Untitled" : cellData.title
        title = isRedacted ? RedactedText.pageTitle : title
        return AnytypeText(title, style: .captionMedium).foregroundColor(.textPrimary)
    }
    
    private var type: some View {
        let type = isRedacted ? RedactedText.pageType : cellData.type
        return AnytypeText(type, style: .footnote).foregroundColor(.textSecondary)
    }
    
    private var icon: some View {
        Group {
            if isRedacted {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.grayscale10)
                    .frame(width: 48, height: 48)
            } else {
                switch cellData.icon {
                case let .emoji(emoji):
                    AnytypeText(emoji.value, name: .inter, size: 48, weight: .regular)
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
    }
    
    private var iconSpacer: some View {
        Group {
            if !cellData.icon.isNil || isRedacted {
                Spacer()
            } else {
                EmptyView()
            }
        }
    }
    
    private var textSpacer: some View {
        Group {
            if !cellData.icon.isNil || isRedacted {
                EmptyView()
            } else {
                Spacer()
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
