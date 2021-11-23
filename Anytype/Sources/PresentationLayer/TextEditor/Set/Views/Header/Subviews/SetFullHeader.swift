import SwiftUI

struct SetFullHeader: View {
    var yOffset: CGFloat
    @Binding var headerSize: CGRect
    @Binding var headerPosition: CGPoint
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack {
            VStack {
                header.ignoresSafeArea(edges: .top)
                PositionCatcher { headerPosition = $0 }
                SetHeaderSettings()
            }
            .background(Color.background)
            .background(FrameCatcher { headerSize = $0 })
            .offset(y: min(yOffset, 0))
            
            Spacer()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            CoverConstants.gradients[1].asLinearGradient()
                .frame(height: 240)
                .ifLet(model.document.objectDetails?.objectIconImage) { view, icon in
                    view.overlay(
                        SwiftUIObjectIconImageView(iconImage: icon, usecase: .openedObject)
                            .frame(width: 96, height: 96)
                            .padding(.leading, 20)
                            .padding(.bottom, -25),
                        alignment: .bottomLeading
                    )
                }
            Spacer.fixedHeight(25)
            AnytypeText("\(model.document.objectDetails?.title ??  "Untitled")", style: .title, color: .textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
            if let description = model.document.objectDetails?.description {
                Spacer.fixedHeight(6)
                AnytypeText(description, style: .body, color: .textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
            }
        }
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader(yOffset: 0, headerSize: .constant(.zero), headerPosition: .constant(.zero))
    }
}
