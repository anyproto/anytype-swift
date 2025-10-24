import SwiftUI
import Services

struct AIChatSummaryView: View {

    @StateObject private var model: AIChatSummaryViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String, chatId: String) {
        self._model = StateObject(wrappedValue: AIChatSummaryViewModel(spaceId: spaceId, chatId: chatId))
    }

    var body: some View {
        NavigationView {
            Group {
                if model.isLoading {
                    ProgressView()
                } else if model.messages.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle("AI Chat Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await model.loadMessages()
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            summarySection
            Divider()
            messagesList
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Summary")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.Text.primary)

            if model.isSummarizing {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Generating summary...")
                        .foregroundColor(.Text.secondary)
                        .font(.system(size: 15))
                }
            } else if let error = model.summaryError {
                VStack(alignment: .leading, spacing: 8) {
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
            } else if model.summary.isEmpty {
                if model.isAIAvailable {
                    Button {
                        Task {
                            await model.generateSummary()
                        }
                    } label: {
                        Label("Generate Summary", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("AI summarization requires iOS 26.0 or later")
                        .foregroundColor(.Text.secondary)
                        .font(.system(size: 15))
                }
            } else {
                Text(model.summary)
                    .foregroundColor(.Text.primary)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color.Background.secondary)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.Background.primary)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("No messages from the last 2 days")
                .foregroundColor(.Text.secondary)
        }
    }

    private var messagesList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(model.messages.count) messages from last 2 days")
                    .foregroundColor(.Text.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ForEach(model.messages, id: \.message.id) { fullMessage in
                    messageRow(fullMessage)
                }
            }
            .padding(.bottom, 16)
        }
    }

    private func messageRow(_ fullMessage: FullChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(fullMessage.message.creator)
                    .foregroundColor(.Text.primary)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(fullMessage.message.createdAtDate, style: .relative)
                    .foregroundColor(.Text.secondary)
                    .font(.system(size: 13))
            }

            Text(fullMessage.message.message.text)
                .foregroundColor(.Text.primary)
                .font(.system(size: 15))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
