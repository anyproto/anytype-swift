import Foundation
import SwiftUI

struct SpaceManagerRowView: View {
    
    let spaceView: SpaceView
    
    var body: some View {
        VStack(spacing: 0) {
            spaceInfo
            spaceStateInfo
        }
        .padding(.horizontal, 16)
        .border(12, color: .Shape.primary)
    }
    
    private var spaceInfo: some View {
        HStack(spacing: 12) {
            IconView(icon: spaceView.iconImage)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(spaceView.name, style: .uxTitle2Semibold, color: .Text.primary)
                AnytypeText("Owner DEMO", style: .relation2Regular, color: .Text.secondary)
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
                statusInfoBlock(title: "Network:", name: "Available DEMO")
                    .frame(width: reader.size.width * 0.5)
                statusInfoBlock(title: "Device:", name: "Stored DEMO")
                    .frame(width: reader.size.width * 0.5)
            }
            .frame(height: 44)
        }
        .frame(height: 44)
    }
    
    
    private func statusInfoBlock(title: String, name: String) -> some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Spacer.fixedWidth(6)
            AnytypeText(title, style: .relation3Regular, color: .Text.secondary)
            Spacer.fixedWidth(4)
            AnytypeText(name, style: .relation3Regular, color: .Text.primary)
        }
    }
}
