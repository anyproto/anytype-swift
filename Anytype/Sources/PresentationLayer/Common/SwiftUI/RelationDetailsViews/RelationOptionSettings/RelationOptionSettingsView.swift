import Foundation
import SwiftUI

struct RelationOptionSettingsView: View {
    
    @StateObject var model: RelationOptionSettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: model.configuration.mode.title)
            content
        }
        .background(Color.Background.secondary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            textField
            
            colorBlock
            
            Spacer()
            
            createButton
            
            Spacer.fixedHeight(10)
        }
        .padding(.horizontal, 20)
    }
    
    private var textField: some View {
        TextField(
            Loc.Relation.Create.Textfield.placeholder,
            text: $model.text
        )
        .foregroundColor(model.selectedColor)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
        .focused(.constant(true))
        .frame(height: 48)
        .newDivider()
    }
    
    private var colorBlock: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.color)
            Spacer.fixedHeight(12)
            LazyVGrid(
                columns: columns()
            ) {
                ForEach(model.colors, id: \.self) { color in
                    colorItem(with: color)
                }
            }
        }
    }
    
    private func colorItem(with color: Color) -> some View {
        Circle()
            .fill(color)
            .onTapGesture {
                model.onColorSelected(color)
            }
            .if(color == model.selectedColor, transform: {
                $0.overlay(alignment: .center) {
                    Image(asset: .X24.tick)
                        .foregroundColor(.Text.white)
                }
            })
    }
    
    private func columns() -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 8, alignment: .topLeading),
            count: 5
        )
    }
    
    private var createButton: some View {
        StandardButton(
            model.configuration.mode.buttonTitle,
            style: .primaryLarge,
            action: {
                model.onButtonTap()
            }
        )
        .disabled(model.text.isEmpty)
    }
    
}

#Preview {
    RelationOptionSettingsView(
        model: RelationOptionSettingsViewModel(
            configuration: RelationOptionSettingsConfiguration(
                option: RelationOptionParameters(id: "", text: nil, color: nil),
                mode: .edit
            ),
            relationsService: DI.preview.serviceLocator.relationService(objectId: ""),
            completion: { _ in }
        )
    )
}
