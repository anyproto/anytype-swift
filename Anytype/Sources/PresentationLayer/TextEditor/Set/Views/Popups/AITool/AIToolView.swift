import SwiftUI
import Services

struct AIToolView: View {
    
    @StateObject var model: AIToolViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: AIToolData) {
        _model = StateObject(wrappedValue: AIToolViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.AITool.title)
            content
        }
        .task(item: model.generateTaskId) { _ in
            await model.generate()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .background(Color.Background.secondary)
        .ignoresSafeArea()
        .fitPresentationDetents()
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            TextField(Loc.AITool.placeholder, text: $model.text, axis: .vertical)
                .lineLimit(1...10)
                .focused(.constant(true))
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .frame(minHeight: 48)
            
            StandardButton(
                Loc.AITool.button,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.generateTap()
                }
            )
        }
        .padding(.horizontal, 20)
    }
}
