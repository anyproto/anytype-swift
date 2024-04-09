import SwiftUI
import AnytypeCore

struct FileStorageView: View {
    
    @StateObject private var model: FileStorageViewModel
    
    init(output: FileStorageModuleOutput?) {
        self._model = StateObject(wrappedValue: FileStorageViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.FileStorage.Local.title)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    locaBlock
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
    }
    
    @ViewBuilder
    private var locaBlock: some View {
        Spacer.fixedHeight(4)
        AnytypeText(Loc.FileStorage.Local.instruction, style: .uxCalloutRegular)
            .foregroundColor(.Text.primary)
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
}
