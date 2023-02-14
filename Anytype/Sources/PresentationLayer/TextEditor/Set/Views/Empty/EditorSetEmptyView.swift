import SwiftUI

struct EditorSetEmptyView: View {
    struct Model {
        let title: String
        let subtitle: String
        let buttonTitle: String
        let onTap: () -> Void
    }

    let model: Model
    
    var body: some View {
        VStack(spacing: 0) {            
            AnytypeText(model.title, style: .uxCalloutRegular, color: .Text.secondary)
            
            Spacer.fixedHeight(4)
            
            AnytypeText(model.subtitle, style: .caption1Regular, color: .Text.secondary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(16)
            
            Button {
                model.onTap()
            } label: {
                AnytypeText(model.buttonTitle, style: .caption1Regular, color: .Text.primary)
                    .padding(EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.Stroke.primary, lineWidth: 1)
                    )
            }
        }
    }
}

struct EditorSetEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSetEmptyView(
            model: .init(
                title: "No query selected",
                subtitle: "All objects satisfying your query will be displayed in Set",
                buttonTitle: "Select query",
                onTap: {}
            )
        )
    }
}
