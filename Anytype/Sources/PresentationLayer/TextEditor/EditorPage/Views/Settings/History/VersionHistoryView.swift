import Foundation
import SwiftUI

struct VersionHistoryView: View {
    
    @StateObject private var model: VersionHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: VersionHistoryData) {
        _model = StateObject(wrappedValue: VersionHistoryViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.VersionHistory.title)
            Spacer()
        }
    }
}
