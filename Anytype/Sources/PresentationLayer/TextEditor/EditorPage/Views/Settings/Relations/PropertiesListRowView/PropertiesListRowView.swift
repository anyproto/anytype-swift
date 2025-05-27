import SwiftUI

struct PropertiesListRowView: View {
    
    @Binding var editingMode: Bool
    let starButtonAvailable: Bool
    let showLocks: Bool
    let addedToObject: Bool
    let relation: Relation
    
    let onRemoveTap: (_ relation: Relation) -> ()
    let onStarTap: (_ relation: Relation) -> ()
    let onEditTap: (_ relation: Relation) -> ()
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        row
            .frame(height: 48)
            .readSize { size = $0 }
    }
    
    private var row: some View {
        HStack(spacing: 8) {
            if editingMode {
                if relation.canBeRemovedFromObject && addedToObject {
                    removeButton
                } else {
                    Spacer.fixedWidth(Constants.buttonWidth)
                }
            }
            
            contentView
        }
    }
    
    private var contentView: some View {
        // If we will use spacing more than 0 it will be added to
        // `Spacer()` from both sides as a result
        // `Spacer` will take up more space
        HStack(spacing: 0) {
            name
            Spacer.fixedWidth(8)
            valueViewButton
            Spacer(minLength: 8)
            if starButtonAvailable {
                starImageView
            }
        }
        .frame(height: size.height)
    }
    
    private var name: some View {
        Menu {
            AnytypeText(relation.name, style: .relation1Regular)
                .foregroundColor(.Text.secondary)
        } label: {
            HStack(spacing: 6) {
                if !relation.isEditable && showLocks {
                    Image(asset: .relationLocked)
                        .tint(.Control.active)
                        .frame(width: 15, height: 12)
                }
                AnytypeText(relation.name, style: .relation1Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
            }
            .frame(width: size.width * 0.4, alignment: .leading)
        }
    }
    
    private var valueViewButton: some View {
        Button {
            onEditTap(relation)
        } label: {
            valueView
        }
    }
    
    private var valueView: some View {
        PropertyValueView(
            model: PropertyValueViewModel(
                property: PropertyItemModel(property: relation),
                style: .regular(allowMultiLine: false),
                mode: .button(action: nil)
            )
        )
    }
    
    private var removeButton: some View {
        withAnimation(.spring()) {
            Button {
                onRemoveTap(relation)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
        }
    }
    
    private var starImageView: some View {
        Button {
            onStarTap(relation)
        } label: {
            relation.isFeatured ?
                Image(asset: .relationRemoveFromFeatured) :
                Image(asset: .relationAddToFeatured)
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
                starButtonAvailable: true,
                showLocks: true,
                addedToObject: true,
                relation: Relation.tag(
                    Relation.Tag(
                        id: "1",
                        key: "1",
                        name: "relation name",
                        isFeatured: false,
                        isEditable: true,
                        canBeRemovedFromObject: false,
                        isDeleted: false,
                        selectedTags: [
                            Relation.Tag.Option(
                                id: "id1",
                                text: "text1",
                                textColor: Color.Dark.teal,
                                backgroundColor: Color.VeryLight.teal
                            ),
                            Relation.Tag.Option(
                                id: "id2",
                                text: "text2",
                                textColor: Color.Dark.red,
                                backgroundColor: Color.VeryLight.teal
                            ),
                            Relation.Tag.Option(
                                id: "id3",
                                text: "text3",
                                textColor: Color.Dark.teal,
                                backgroundColor: Color.VeryLight.teal
                            ),
                            Relation.Tag.Option(
                                id: "id4",
                                text: "text4",
                                textColor: Color.Dark.red,
                                backgroundColor: Color.VeryLight.teal
                            )
                        ]
                    )
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
            RelationsListRowView(
                editingMode: .constant(false),
                starButtonAvailable: true,
                showLocks: true,
                addedToObject: true,
                relation: Relation.text(
                    Relation.Text(
                        id: "1",
                        key: "1",
                        name: "Relation name",
                        isFeatured: false,
                        isEditable: true,
                        canBeRemovedFromObject: false,
                        isDeleted: false,
                        value: "hello"
                    )
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
        }
    }
}
