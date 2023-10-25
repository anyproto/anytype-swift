import Foundation
import SwiftUI

struct SpaceRowModel: Identifiable {
    let id: String
    let title: String
    let icon: Icon?
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: (() -> Void)?
}

struct SpaceRowView: View {
    
    static let width: CGFloat = 96
    
    let model: SpaceRowModel
    
    var body: some View {
        VStack {
            IconView(icon: model.icon)
                .frame(width: Self.width, height: 96)
                .cornerRadius(8)
                .shadow(color: .Shadow.primary, radius: 20)
                .padding(3)
                .if(model.isSelected) {
                    $0.border(10, color: .Text.white, lineWidth: 3)
                }
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 8))
                .contextMenu {
                    if let onDelete = model.onDelete {
                        Button(Loc.SpaceSettings.deleteButton, role: .destructive) {
                            onDelete()
                        }
                    }
                }
            Spacer()
            AnytypeText(model.title, style: .caption1Medium, color: .Text.white)
        }
        .frame(width: Self.width, height: 126)
        .onTapGesture {
            if !model.isSelected {
                model.onTap()
            }
        }
    }
}
