import SwiftUI

struct ObjectRow {
    
    let icon: ObjectIconImageModel
    let title: String
    let subtitle: String
    let selectionIndex: Int?
    
}

struct ObjectRowView: View {
    
    let row: ObjectRow
    let onTap: (() -> Void)?
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            view
        }
    }
    
    private var view: some View {
        HStack(spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: row.icon.iconImage,
                usecase: row.icon.usecase
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            content
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                text
                Spacer(minLength: 12)
                selectedIndex
            }
            Spacer()
            AnytypeDivider()
        }
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(row.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
            Spacer.fixedHeight(1)
            AnytypeText(row.subtitle, style: .relation2Regular, color: .textSecondary)
                .lineLimit(1)
        }
    }
    
    private var selectedIndex: some View {
        row.selectionIndex
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { index in
                AnytypeText("\(index)", style: .relation1Regular, color: .textWhite)
                    .lineLimit(1)
                    .frame(width:24, height: 24)
                    .background(Color.System.amber)
                    .clipShape(Circle())
            }
    }
}

struct ObjectRowView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRowView(
            row: ObjectRow(
                icon: .init(iconImage: .todo(false), usecase: .dashboardSearch), title: "TitleTitleTitleTitleTitleTitleTitleTitleTitleTitle", subtitle: "Subtitle", selectionIndex: 1)
        ) {
                
            }
    }
}
