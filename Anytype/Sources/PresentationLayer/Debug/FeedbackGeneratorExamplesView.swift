import SwiftUI
import UIKit

struct FeedbackGeneratorExamplesView: View {
    
    private let sections: [SectionModel] = makeSections()
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Feedback Generators")
            list
        }
    }
    
    private var list: some View {
        List(sections) { section in
            Section(
                header: Text(section.title),
                footer: Text(section.description)
            ) {
                ForEach(section.examples) { example in
                    Button {
                        handleTapOnExample(example)
                    } label: {
                        AnytypeText(example.title, style: .uxBodyRegular, color: .Text.primary)
                    }
                }
            }
        }
    }
    
    private func handleTapOnExample(_ example: FeedbackGeneratorExample) {
        switch example {
        case .notification(let feedbackType):
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .impact(let feedbackStyle):
            UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
        }
    }
    
}

private extension FeedbackGeneratorExamplesView {
    
    struct SectionModel: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let description: String
        let examples: [FeedbackGeneratorExample]
    }
    
}

private extension FeedbackGeneratorExamplesView {
    
    static func makeSections() -> [SectionModel] {
        [
            SectionModel(
                title: "Impact Feedback Generator",
                description: "Use impact feedback generators to indicate that an impact has occurred. For example, you might trigger impact feedback when a user interface object collides with something or snaps into place",
                examples: UIImpactFeedbackGenerator.FeedbackStyle.feedbackTypes.map {
                    FeedbackGeneratorExample.impact($0)
                }
            ),
            SectionModel(
                title: "Selection Feedback Generator",
                description: "Use selection feedback generators to indicate a change in selection",
                examples: [.selection]
            ),
            SectionModel(
                title: "Notification Feedback Generator",
                description: "Use notification feedback generators to indicate successes, failures, and warnings",
                examples: UINotificationFeedbackGenerator.FeedbackType.feedbackTypes.map {
                    FeedbackGeneratorExample.notification($0)
                }
            )
        ]
    }
    
}

struct FeedbackGeneratorExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackGeneratorExamplesView()
    }
}
