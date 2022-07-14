import SwiftUI

struct EditorSetViewPicker: View {
    @ObservedObject var viewModel: EditorSetViewPickerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.views)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    Spacer.fixedHeight(10)
                    
                    ForEach(viewModel.rows) {
                        viewButton($0)
                    }
                }
            }
        }
        .background(Color.backgroundSecondary)
    }
    
    func viewButton(_ configuration: EditorSetViewRowConfiguration) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            HStack(spacing: 0) {
                if configuration.isSupported {
                    Button(action: {
                        configuration.onTap()
                        withAnimation(.fastSpring) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        AnytypeText(configuration.name, style: .uxBodyRegular, color: .textPrimary)
                        Spacer(minLength: 5)
                        if configuration.isActive {
                            Image.optionChecked
                        }
                    }
                } else {
                    AnytypeText("\(configuration.name)", style: .uxBodyRegular, color: .textSecondary)
                    Spacer(minLength: 5)
                    AnytypeText("\(configuration.typeName) view soon", style: .uxBodyRegular, color: .textSecondary)
                }
            }
            .divider(spacing: 14)
            .padding(.horizontal, 20)
        }
    }
}
