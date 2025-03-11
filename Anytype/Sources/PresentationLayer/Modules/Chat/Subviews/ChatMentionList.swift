import Foundation
import SwiftUI
import Services

// The same as EditorSearchCell for UIKit
struct ChatMentionList: View {
    
    private enum Constants {
        static let itemHeight: CGFloat = 56
        static let maxVisibleItems: CGFloat = 3.5
    }
    
    let models: [MentionObjectModel]
    let didSelect: (_ object: MentionObject) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(models) { model in
                    cell(for: model)
                }
            }
        }
        .background(Color.Background.primary)
        .frame(maxHeight: Constants.itemHeight * min(CGFloat(models.count), Constants.maxVisibleItems))
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }
    
    private func cell(for model: MentionObjectModel) -> some View {
        HStack(spacing: 12) {
            IconView(icon: model.object.objectIcon)
                .frame(width: 40, height: 40)
            textContent(for: model)
            Spacer()
        }
        .frame(height: Constants.itemHeight)
        .padding(.horizontal, 20)
        .newDivider(leadingPadding: 72)
        .fixTappableArea()
        .onTapGesture {
            didSelect(model.object)
        }
    }
    
    private func textContent(for model: MentionObjectModel) -> some View {
        VStack(alignment: .leading) {
            title(for: model)
            Text(model.object.details.objectType.displayName)
                .anytypeStyle(.relation2Regular)
                .foregroundStyle(Color.Text.secondary)
                .lineLimit(1)
        }
    }
    
    private func title(for model: MentionObjectModel) -> some View {
        HStack(spacing: 4) {
            Text(model.object.details.title)
                .anytypeStyle(.uxTitle2Regular)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
            if let badge = model.titleBadge {
                Text(badge)
                    .anytypeStyle(.relation2Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
            }
        }
    }
}
