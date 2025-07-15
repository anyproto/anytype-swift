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
    let showSyncIndicator: Bool
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
        if showSyncIndicator {
            syncIndicatorText
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
            showSyncIndicator: data.showMessageSyncIndicator,
            createDate: data.createDate
        )
    }
}
