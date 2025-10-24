import SwiftUI
import Services
import UIKit

@available(iOS 26.0, *)
struct AIChatSummaryView: View {

    @StateObject private var model: AIChatSummaryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    @State private var toastBarData: ToastBarData?

    init(spaceId: String, chatId: String) {
        self._model = StateObject(wrappedValue: AIChatSummaryViewModel(spaceId: spaceId, chatId: chatId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                if model.isSummarizing {
                    if #available(iOS 26.0, *) {
                        AppleIntelligenceGlowEffect()
                            .ignoresSafeArea()
                            .onAppear {
                                feedbackGenerator.prepare()
                                feedbackGenerator.impactOccurred()
                            }
                    } else {
                        EmptyView()
                    }
                }

                Group {
                    if model.isLoading {
                        loadingView
                    } else if model.messages.isEmpty {
                        emptyView
                    } else {
                        summaryContentView
                    }
                }
            }
            .navigationTitle("Recent Messages Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .snackbar(toastBarData: $toastBarData)
        .animation(.default, value: model.isLoading)
        .sheet(item: $model.selectedMessage) { message in
            messageDetailView(message)
        }
        .task {
            await model.loadMessages()
            if !model.messages.isEmpty && model.isAIAvailable {
                await model.generateSummary()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading messages...")
                .foregroundColor(.Text.secondary)
                .font(.system(size: 15))
        }
    }

    private var summaryContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                messageCountText
                    .font(.system(size: 14))
                    .foregroundColor(.Text.secondary)
                    .padding(.top, 20)

                summaryContent
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            }
        }
    }

    private var messageCountText: some View {
        Group {
            if let analyzed = model.messagesAnalyzed, analyzed < model.messages.count {
                Text("\(model.messages.count) messages from last 2 days (showing last \(analyzed) due to context limit)")
            } else {
                Text("\(model.messages.count) messages from last 2 days")
            }
        }
    }

    private var summaryContent: some View {
        Group {
            if model.isSummarizing {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Generating summary...")
                        .foregroundColor(.Text.secondary)
                        .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if let error = model.summaryError {
                VStack(alignment: .leading, spacing: 12) {
                    Text(error)
                        .foregroundColor(.Pure.red)
                        .font(.system(size: 15))
                    if model.isAIAvailable {
                        Button("Try Again") {
                            Task {
                                await model.generateSummary()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } else if model.summary == nil {
                Text("Summary not available")
                    .foregroundColor(.Text.secondary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
            } else if let summary = model.summary {
                VStack(alignment: .leading, spacing: 20) {
                    if !summary.keyPoints.isEmpty {
                        summarySection(title: "Key Points:", items: summary.keyPoints)
                    }

                    if !summary.topics.isEmpty {
                        summarySection(title: "Topics:", items: summary.topics)
                    }
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("No messages from the last 2 days")
                .foregroundColor(.Text.secondary)
                .font(.system(size: 15))
        }
    }

    private func summarySection(title: String, items: [SummaryPoint]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxTitle1Semibold))
                .foregroundColor(.Text.primary)

            ForEach(items) { item in
                Button(action: {
                    handleBulletTap(item)
                }) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(item.text)
                            .foregroundColor(.blue)
                            .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func handleBulletTap(_ item: SummaryPoint) {
        if let messageId = item.relatedMessageId,
           let message = model.findMessage(byId: messageId) {
            model.selectedMessage = message
        } else {
            toastBarData = ToastBarData("No specific message linked to this item", type: .neutral)
        }
    }

    private func messageDetailView(_ message: FullChatMessage) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(message.message.creator)
                        .font(AnytypeFontBuilder.font(anytypeFont: .uxTitle1Semibold))
                        .foregroundColor(.Text.primary)

                    Text(message.message.createdAtDate, style: .relative)
                        .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
                        .foregroundColor(.Text.secondary)

                    Divider()

                    Text(message.message.message.text)
                        .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                        .foregroundColor(.Text.primary)
                }
                .padding(20)
            }
            .navigationTitle("Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        model.selectedMessage = nil
                    }
                }
            }
        }
    }
}
