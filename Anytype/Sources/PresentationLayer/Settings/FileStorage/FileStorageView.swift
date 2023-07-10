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
                    Spacer.fixedHeight(24)
                    spaceBlock
                    Spacer.fixedHeight(44)
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
    private var spaceBlock: some View {
        AnytypeText(Loc.FileStorage.Space.title, style: .uxTitle1Semibold, color: .Text.primary)
        Spacer.fixedHeight(4)
        AnytypeText(model.spaceInstruction, style: .uxCalloutRegular, color: .Text.primary)
        if model.showGetMoreSpaceButton {
            Spacer.fixedHeight(4)
            AnytypeText(Loc.FileStorage.Space.getMore, style: .uxCalloutMedium, color: .System.red)
                .onTapGesture {
                    model.onTapGetMoreSpace()
                }
        }
        Spacer.fixedHeight(16)
        FileStorageInfoBlock(iconImage: model.spaceIcon, title: model.spaceName, description: model.spaceUsed, isWarning: model.spaceUsedWarning)
        Spacer.fixedHeight(8)
        LineProgressBar(percent: model.percentUsage, configuration: model.progressBarConfiguration)
        Spacer.fixedHeight(20)
        StandardButton(.text(Loc.FileStorage.manageFiles), style: .secondarySmall) {
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
            description: model.locaUsed,
            isWarning: false
        )
        Spacer.fixedHeight(8)
        StandardButton(.text(Loc.FileStorage.offloadTitle), style: .secondarySmall) {
            model.onTapOffloadFiles()
        }
    }
}
