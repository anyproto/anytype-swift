import SwiftUI
import AnytypeCore

struct FileStorageView: View {
    
    @ObservedObject var model: FileStorageViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.FileStorage.title)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer.fixedHeight(16)
                    spaceBlock
                    Spacer.fixedHeight(44)
                    locaBlock
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private var spaceBlock: some View {
        AnytypeText(model.spaceInstruction, style: .uxCalloutRegular, color: .Text.primary)
        Spacer.fixedHeight(16)
        FileStorageInfoBlock(iconImage: model.spaceIcon, title: model.spaceName, description: model.spaceUsed)
        Spacer.fixedHeight(8)
        FileStorageProgress(percent: model.percentUsage)
        Spacer.fixedHeight(20)
        StandardButton(Loc.FileStorage.manageFiles, style: .secondarySmall) {
            model.onTapManageFiles()
        }
    }
    
    @ViewBuilder
    private var locaBlock: some View {
        AnytypeText(Loc.FileStorage.Local.title, style: .uxTitle1Semibold, color: .Text.primary)
        Spacer.fixedHeight(4)
        AnytypeText(Loc.FileStorage.Local.instruction, style: .uxCalloutRegular, color: .Text.primary)
        Spacer.fixedHeight(16)
        FileStorageInfoBlock(
            iconImage: Emoji("📱").map { ObjectIconImage.icon(.emoji($0)) },
            title: model.phoneName,
            description: model.locaUsed
        )
        Spacer.fixedHeight(6)
        StandardButton(Loc.FileStorage.offloadTitle, style: .secondarySmall) {
            model.onTapOffloadFiles()
        }
    }
}
