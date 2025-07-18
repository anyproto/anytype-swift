import SwiftUI

struct SetTableViewHeader: View {
    @ObservedObject var model: EditorSetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeDivider()
            content
            AnytypeDivider()
        }
    }
    
    private var content: some View {
        LazyHStack(spacing: 0) {
            ForEach(model.colums, id: \.key) { data in
                HStack(spacing: 0) {
                    Spacer.fixedWidth(15)
                    if data.isReadOnlyValue || !model.setDocument.setPermissions.canEditRelationValuesInView {
                        Image(asset: .relationLockedSmall)
                            .tint(.Control.secondary)
                        Spacer.fixedWidth(4)
                    }
                    AnytypeText(data.name, style: .relation2Regular)
                .foregroundColor(.Text.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                }.frame(width: 144)
                
                Rectangle()
                    .frame(width: .onePixel, height: 18)
                    .foregroundColor(.Shape.primary)
            }
        }
        .frame(height: 40)
    }
}

struct SetTableViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetTableViewHeader(model: EditorSetViewModel.emptyPreview)
    }
}
