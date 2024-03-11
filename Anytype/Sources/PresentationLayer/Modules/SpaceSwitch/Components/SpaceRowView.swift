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
    
    private enum Constants {
        static let lineWidth: CGFloat = 3
    }
    
    static let width: CGFloat = 96
    
    let model: SpaceRowModel
    
    var body: some View {
        VStack {
            ZStack {
                IconView(icon: model.icon)
                    .frame(width: Self.width, height: Self.width)
                    .if(model.isSelected) {
                        $0.padding(Constants.lineWidth / 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.Text.white, lineWidth: Constants.lineWidth)
                        )
                    }
                .frame(width: Self.width + additionalSize, height: Self.width + additionalSize)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 2))
                .contextMenu {
                    if let onDelete = model.onDelete {
                        Button(Loc.SpaceSettings.deleteButton, role: .destructive) {
                            onDelete()
                        }
                    }
                }
            }
            .frame(width: Self.width, height: Self.width)
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
    
    private var additionalSize: CGFloat {
        return model.isSelected ? Constants.lineWidth * 2.0 : 0
    }
}
