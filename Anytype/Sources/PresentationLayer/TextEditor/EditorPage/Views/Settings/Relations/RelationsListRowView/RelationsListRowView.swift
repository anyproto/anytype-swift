import SwiftUI

struct RelationsListRowView: View {
    
    @Binding var editingMode: Bool
    let starButtonAvailable: Bool
    let relation: Relation
    
    let onRemoveTap: (String) -> ()
    let onStarTap: (String) -> ()
    let onEditTap: (String) -> ()
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        row
            .frame(height: 48)
            .readSize { size = $0 }
    }
    
    private var row: some View {
        HStack(spacing: 8) {
            if editingMode {
                if !relation.isBundled {
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
            
            if relation.isEditable {
                valueViewButton
            } else {
                valueView
            }
            
            Spacer(minLength: 8)
            if starButtonAvailable {
                starImageView
            }
        }
        .frame(height: size.height)
        .divider()
    }
    
    private var name: some View {
        Menu {
            AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary)
        } label: {
            HStack(spacing: 6) {
                if !relation.isEditable {
                    Image(asset: .relationLocked)
                        .frame(width: 15, height: 12)
                }
                AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary).lineLimit(1)
            }
            .frame(width: size.width * 0.4, alignment: .leading)
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
        RelationValueView(
            relation: RelationItemModel(relation: relation),
            style: .regular(allowMultiLine: false), action: nil
        )
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
                relation: Relation.tag(
                    Relation.Tag(
                        id: "1",
                        name: "relation name",
                        isFeatured: false,
                        isEditable: true,
                        isBundled: false,
                        selectedTags: [
                            Relation.Tag.Option(
                                id: "id1",
                                text: "text1",
                                textColor: UIColor.Text.teal,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id2",
                                text: "text2",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id3",
                                text: "text3",
                                textColor: UIColor.Text.teal,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id4",
                                text: "text4",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            )
                        ],
                        allTags: [
                            Relation.Tag.Option(
                                id: "id1",
                                text: "text1",
                                textColor: UIColor.Text.teal,
                                backgroundColor: .backgroundDashboard,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id2",
                                text: "text2",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.red,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id3",
                                text: "text3",
                                textColor: UIColor.Text.teal,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id4",
                                text: "text4",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.red,
                                scope: .local
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
                relation: Relation.text(
                    Relation.Text(
                        id: "1",
                        name: "Relation name",
                        isFeatured: false,
                        isEditable: true,
                        isBundled: false,
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
