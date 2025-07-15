import SwiftUI

// Return Text type. Needed for "+" operations.
extension Text {
    @MainActor
    init(messageBottomInfo data: MessageViewData) {
        self = MessageBottomInfoViewBuilder(data: data).body
    }
}

@MainActor
private struct MessageBottomInfoViewBuilder {
    
    let synced: Bool
    let edited: Bool
    let isYour: Bool
    let createDate: String
    
    var body: Text {
        infoText
            .anytypeFontStyle(.caption2Regular)
    }
    
    private var infoText: Text {
        let editText = edited ? Loc.Message.edited + " " : ""
        return Text("  ") + syncIndicator + Text(editText + createDate)
    }
    
    private var syncIndicator: Text {
        if isYour {
            if synced {
                syncIndicatorText
                    .foregroundColor(.clear)
            } else {
                syncIndicatorText
            }
        } else {
            Text("")
        }
    }
    
    private var syncIndicatorText: Text {
        Text(Image(asset: synced ? .MessageStatus.synced : .MessageStatus.loading))
            .baselineOffset(-2)
        + Text(" ")
    }
}

private extension MessageBottomInfoViewBuilder {
    init(data: MessageViewData) {
        self.init(
            synced: data.message.synced,
            edited: data.message.modifiedAtDate != nil,
            isYour: data.position.isRight,
            createDate: data.createDate
        )
    }
}
