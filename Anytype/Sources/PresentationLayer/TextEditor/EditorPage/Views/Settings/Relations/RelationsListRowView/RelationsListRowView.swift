import SwiftUI

struct RelationsListRowView: View {
    
    @Binding var editingMode: Bool
    let relation: Relation
    
    let onRemoveTap: (String) -> ()
    let onStarTap: (String) -> ()
    let onEditTap: (String) -> ()
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 8) {
                if editingMode {
                    if relation.isEditable {
                        removeButton
                    } else {
                        Spacer.fixedWidth(Constants.buttonWidth)
                    }
                }
                
                // If we will use spacing more than 0 it will be added to
                // `Spacer()` from both sides as a result
                // `Spacer` will take up more space
                HStack(spacing: 0) {
                    name
                        .frame(width: gr.size.width * 0.4, alignment: .leading)
                    Spacer.fixedWidth(8)
                    
                    if relation.isEditable {
                        valueViewButton
                    } else {
                        valueView
                    }
                    
                    Spacer(minLength: 8)
                    starImageView
                }
                .frame(height: gr.size.height)
                .modifier(DividerModifier(spacing:0))
            }
        }
        .frame(height: 48)
    }
    
    private var name: some View {
        HStack(spacing: 6) {
            if !relation.isEditable {
                Image.Relations.locked
                    .frame(width: 15, height: 12)
            }
            AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary).lineLimit(1)
        }
    }
    
    private var valueViewButton: some View {
        Button {
            onEditTap(relation.id)
        } label: {
            valueView
        }
    }
    
    private var valueView: some View {
        HStack(spacing: 0) {
            RelationValueView(relation: relation, style: .regular(allowMultiLine: false))
            Spacer()
        }
    }
    
    private var removeButton: some View {
        withAnimation(.spring()) {
            Button {
                onRemoveTap(relation.id)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
        }
    }
    
    private var starImageView: some View {
        Button {
            onStarTap(relation.id)
        } label: {
            relation.isFeatured ?
            Image.Relations.removeFromFeatured :
            Image.Relations.addToFeatured
        }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
    }
}

private extension RelationsListRowView {
    
    enum Constants {
        static let buttonWidth: CGFloat = 24
    }
    
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation(
                    id: "1", name: "Relation name",
                    value: .tag([
                        TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                        TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                        TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                        TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                    ]),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: true
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation(
                    id: "1", name: "Relation name",
                    value: .text("hello"),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: false
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
        }
    }
}
