import SwiftUI
import BlocksModels

struct EditorSetViewPicker: View {
    
    @ObservedObject var setModel: EditorSetViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.views)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    Spacer.fixedHeight(10)
                    
                    ForEach(setModel.dataView.views) { view in
                        viewButton(view)
                    }
                }
            }
        }
        .background(Color.backgroundSecondary)
    }
    
    func viewButton(_ view: DataviewView) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            HStack(spacing: 0) {
                if view.isSupported {
                    Button(action: {
                        setModel.updateActiveViewId(view.id)
                        withAnimation(.fastSpring) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        AnytypeText(view.name, style: .uxBodyRegular, color: .textPrimary)
                        Spacer(minLength: 5)
                        if view == setModel.activeView {
                            Image.optionChecked
                        }
                    }
                } else {
                    AnytypeText("\(view.name)", style: .uxBodyRegular, color: .textSecondary)
                    Spacer(minLength: 5)
                    AnytypeText("\(view.type.name) view soon", style: .uxBodyRegular, color: .textSecondary)
                }
            }
            .divider(spacing: 14)
            .padding(.horizontal, 20)
        }
    }
}
