import Foundation
import SwiftUI
import Services

struct SpacesManagerRowViewModel: Identifiable {
    let id: String
    let name: String
    let iconImage: Icon?
    let accountStatus: String
    let localStatus: String
    let permission: String
}

struct SpacesManagerRowView: View {
    
    let model: SpacesManagerRowViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            spaceInfo
            spaceStateInfo
        }
        .padding(.horizontal, 16)
        .border(12, color: .Shape.primary)
        .lineLimit(1)
    }
    
    private var spaceInfo: some View {
        HStack(spacing: 12) {
            IconView(icon: model.iconImage)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.name, style: .uxTitle2Semibold, color: .Text.primary)
                AnytypeText(model.permission, style: .relation2Regular, color: .Text.secondary)
            }
            Spacer()
            Button {
                // TODO: Add actions
            } label: {
                IconView(icon: .asset(.X24.more))
                    .frame(width: 24, height: 24)
            }
        }
        .frame(height: 80)
        .newDivider()
    }
    
    private var spaceStateInfo: some View {
        GeometryReader { reader in
            HStack(spacing: 0) {
                statusInfoBlock(title: Loc.Spaces.Info.network, name: model.accountStatus)
                    .frame(width: reader.size.width * 0.5)
                statusInfoBlock(title: Loc.Spaces.Info.device, name: model.localStatus)
                    .frame(width: reader.size.width * 0.5)
            }
            .frame(height: 44)
        }
        .frame(height: 44)
    }
    
    
    private func statusInfoBlock(title: String, name: String) -> some View {
        HStack(spacing: 0) {
            Spacer.fixedWidth(6)
            AnytypeText(title, style: .relation3Regular, color: .Text.secondary)
            Spacer.fixedWidth(4)
            AnytypeText(name, style: .relation3Regular, color: .Text.primary)
            Spacer()
        }
    }
}
