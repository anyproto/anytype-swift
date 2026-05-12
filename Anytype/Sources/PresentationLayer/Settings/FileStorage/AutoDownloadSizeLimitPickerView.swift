import SwiftUI

struct AutoDownloadSizeLimitPickerView: View {

    let selectedLimit: AutoDownloadSizeLimit
    let onSelect: (AutoDownloadSizeLimit) -> Void

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.FileStorage.AutoDownload.title)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(AutoDownloadSizeLimit.allCases) { limit in
                        Button {
                            onSelect(limit)
                        } label: {
                            row(for: limit)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.Background.secondary)
    }

    private func row(for limit: AutoDownloadSizeLimit) -> some View {
        HStack(spacing: 0) {
            AnytypeText(limit.title, style: .uxBodyRegular)
                .foregroundStyle(Color.Text.primary)
            Spacer()
            if limit == selectedLimit {
                Image(asset: .X24.tick)
                    .foregroundStyle(Color.Control.secondary)
            }
        }
        .padding(.vertical, 14)
    }
}
