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
        Group {
            switch cellData.title {
            case let .default(title):
                defaultTitle(with: title)
            case let .todo(title, isChecked):
                todoTitle(with: title, isChecked: isChecked)
            }
        }
    }
    
    private func defaultTitle(with text: String) -> some View {
        var titleString = text.isEmpty ? "Untitled".localized : text
        titleString = isRedacted ? RedactedText.pageTitle : titleString
        
        return AnytypeText(titleString, style: .captionMedium).foregroundColor(.textPrimary)
    }
    
    private func todoTitle(with text: String, isChecked: Bool) -> some View {
        HStack(alignment: .top, spacing: 6) {
            isChecked ?
                Image.Title.TodoLayout.checkmark
                .resizable()
                .frame(width: 18, height: 18) :
                Image.Title.TodoLayout.checkbox
                .resizable()
                .frame(width: 18, height: 18)
            
            defaultTitle(with: text)
        }
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
                case let .basic(basicIcon):
                    makeBasicIconView(basicIcon)
                case let .profile(profileIcon):
                    makeProfileIconView(profileIcon)
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    private func makeBasicIconView(_ basicIcon: DocumentIconType.Basic) -> some View {
        Group {
            switch basicIcon {
            case let .emoji(emoji):
                AnytypeText(emoji.value, name: .inter, size: 48, weight: .regular)
            case let .imageId(imageId):
                AsyncImage(
                    imageId: imageId,
                    parameters: ImageParameters(width: .thumbnail)
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 48)
                .cornerRadius(10)
            }
        }
        
    }
    
    private func makeProfileIconView(_ profileIcon: DocumentIconType.Profile) -> some View {
        Group {
            switch profileIcon {
            case let .imageId(imageId):
                AsyncImage(
                    imageId: imageId,
                    parameters: ImageParameters(width: .thumbnail)
                )
                .frame(width: 48, height: 48)
                .aspectRatio(contentMode: .fill)
                .cornerRadius(10)
                
            case let .placeholder(character):
                AnytypeText(
                    String(character),
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
                .frame(maxWidth: 48, maxHeight: 48)
                .foregroundColor(.grayscaleWhite)
                .background(Color.grayscale30)
                
            }
        }
        .clipShape(Circle())
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
