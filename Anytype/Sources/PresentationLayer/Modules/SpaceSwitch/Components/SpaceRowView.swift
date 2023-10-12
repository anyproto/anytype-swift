import Foundation
import SwiftUI

struct SpaceRowModel {
    let id: String
    let title: String
    let icon: Icon?
    let isSelected: Bool
    let onTap: () -> Void
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
                .if(model.isSelected) {
                    $0.border(8, color: .Text.white, lineWidth: 3)
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
