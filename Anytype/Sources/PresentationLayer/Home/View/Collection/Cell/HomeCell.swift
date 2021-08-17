import SwiftUI
import Kingfisher

// figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=4061%3A0
struct HomeCell: View {
    var cellData: HomeCellData
    
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
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 13, trailing: 16))
        .background(Color.background)
        .cornerRadius(16)
        .redacted(reason: isRedacted ? .placeholder : [])
    }
    
    private var title: some View {
        Group {
            switch cellData.title {
            case let .default(title):
                defaultTitle(with: title, lineLimit: cellData.icon.isNil ? nil : 1)
            case let .todo(title, isChecked):
                todoTitle(with: title, isChecked: isChecked)
            }
        }
    }
    
    private func defaultTitle(with text: String, lineLimit: Int?) -> some View {
        var titleString = text.isEmpty ? "Untitled".localized : text
        titleString = isRedacted ? RedactedText.pageTitle : titleString
        
        return AnytypeText(titleString, style: .body)
            .foregroundColor(.textPrimary)
            .lineLimit(lineLimit)
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
            
            defaultTitle(with: text, lineLimit: nil).multilineTextAlignment(.leading)
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
                    cornerRadius: DashboardObjectIcon.Constants.basicImageIconCornerRadius
                )
                    .foregroundColor(Color.grayscale10)
                    .frame(
                        width: DashboardObjectIcon.Constants.iconSize.width,
                        height: DashboardObjectIcon.Constants.iconSize.height
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
                Spacer(minLength: 12)
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
                Spacer(minLength: 2)
            }
        }
    }
}


struct HomeCell_Previews: PreviewProvider {
    static let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    static var previews: some View {
        ScrollView() {
            LazyVGrid(columns: columns) {
                ForEach(HomeCellDataMock.data) { data in
                    HomeCell(cellData: data)
                }
            }
            .padding()
        }
        .background(Color.orange.ignoresSafeArea())
    }
}
