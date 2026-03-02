import SwiftUI
import AnytypeCore

struct FileStorageView: View {

    @State private var model = FileStorageViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.FileStorage.Local.title)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    locaBlock
                    offlineAccessBlock
                }
                .padding(.horizontal, 20)
            }
            .if(!model.contentLoaded) {
                $0.redacted(reason: .placeholder)
                  .allowsHitTesting(false)
            }
        }
        .onAppear {
            model.onAppear()
        }
        .task {
            await model.startSubscription()
        }
        .anytypeSheet(isPresented: $model.showClearCacheAlert) {
            DashboardClearCacheAlert()
        }
        .anytypeSheet(isPresented: $model.showSizeLimitPicker) {
            AutoDownloadSizeLimitPickerView(
                selectedLimit: model.autoDownloadSizeLimit,
                onSelect: { model.onSizeLimitSelected($0) }
            )
        }
    }

    @ViewBuilder
    private var locaBlock: some View {
        Spacer.fixedHeight(4)
        AnytypeText(Loc.FileStorage.Local.instruction, style: .uxCalloutRegular)
            .foregroundStyle(Color.Text.primary)
        Spacer.fixedHeight(16)
        FileStorageInfoBlock(
            iconImage: Emoji("📱").map { Icon.object(.emoji($0)) },
            title: model.phoneName,
            description: model.locaUsed,
            isWarning: false
        )
        Spacer.fixedHeight(8)
        StandardButton(Loc.FileStorage.offloadTitle, style: .secondarySmall) {
            model.onTapOffloadFiles()
        }
    }

    @ViewBuilder
    private var offlineAccessBlock: some View {
        Spacer.fixedHeight(24)
        AnytypeText(Loc.FileStorage.AutoDownload.sectionTitle, style: .caption1Medium)
            .foregroundStyle(Color.Text.secondary)
        Spacer.fixedHeight(8)
        VStack(spacing: 0) {
            offlineDownloadsRow
            if model.autoDownloadSizeLimit.isEnabled {
                useCellularDataRow
            }
        }
        .background(Color.Background.secondary)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var offlineDownloadsRow: some View {
        Button {
            model.showSizeLimitPicker = true
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    AnytypeText(Loc.FileStorage.AutoDownload.title, style: .uxBodyRegular)
                        .foregroundStyle(Color.Text.primary)
                    AnytypeText(Loc.FileStorage.AutoDownload.subtitle, style: .caption1Regular)
                        .foregroundStyle(Color.Text.secondary)
                }
                Spacer()
                HStack(spacing: 8) {
                    AnytypeText(model.autoDownloadSizeLimit.title, style: .bodyRegular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                    Image(asset: .RightAttribute.disclosure)
                        .renderingMode(.template)
                        .foregroundStyle(Color.Control.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private var useCellularDataRow: some View {
        HStack(spacing: 0) {
            AnytypeText(Loc.FileStorage.AutoDownload.useCellularData, style: .uxBodyRegular)
                .foregroundStyle(Color.Text.primary)
            Spacer()
            Toggle("", isOn: Binding(
                get: { model.autoDownloadUseCellular },
                set: { model.onUseCellularToggled($0) }
            ))
            .labelsHidden()
            .tint(Color.Control.accent80)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
