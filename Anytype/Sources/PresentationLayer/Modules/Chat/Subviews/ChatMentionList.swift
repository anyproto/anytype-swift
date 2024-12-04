import Foundation
import SwiftUI
import Services

// The same as EditorSearchCell for UIKit
struct ChatMentionList: View {
    
    private enum Constants {
        static let itemHeight: CGFloat = 56
        static let maxVisibleItems: CGFloat = 3.5
    }
    
    let mentions: [MentionObject]
    let didSelect: (_ object: MentionObject) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(mentions) { mention in
                    HStack(spacing: 12) {
                        IconView(icon: mention.objectIcon)
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(mention.details.title)
                                .anytypeStyle(.uxTitle2Regular)
                                .foregroundStyle(Color.Text.primary)
                                .lineLimit(1)
                            Text(mention.details.objectType.name)
                                .anytypeStyle(.caption1Regular)
                                .foregroundStyle(Color.Text.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .frame(height: Constants.itemHeight)
                    .overlay(alignment: .bottom) {
                        AnytypeDivider()
                    }
                    .padding(.horizontal, 20)
                    .fixTappableArea()
                    .onTapGesture {
                        didSelect(mention)
                    }
                }
            }
        }
        .background(Color.Background.primary)
        .frame(maxHeight: Constants.itemHeight * min(CGFloat(mentions.count), Constants.maxVisibleItems))
        .overlay(alignment: .top) {
            AnytypeDivider()
        }
        .padding(.bottom, 4)
    }
}
