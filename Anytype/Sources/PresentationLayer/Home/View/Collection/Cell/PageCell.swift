import SwiftUI
import Kingfisher

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
                RoundedRectangle(
                    cornerRadius: DashboardObjectIcon.Constants.Basic.cornerRadius
                )
                    .foregroundColor(Color.grayscale10)
                    .frame(
                        width: DashboardObjectIcon.Constants.Basic.imageSize.width,
                        height: DashboardObjectIcon.Constants.Basic.imageSize.height
                    )
            } else {
                switch cellData.icon {
                case .some(let icon):
                    DashboardObjectIcon(icon: icon)
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
