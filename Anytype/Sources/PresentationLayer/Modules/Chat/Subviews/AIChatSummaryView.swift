import SwiftUI
import Services
import UIKit

struct AIChatSummaryView: View {

    @StateObject private var model: AIChatSummaryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

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
        .animation(.default, value: model.isLoading)
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
                Text("\(model.messages.count) messages from last 2 days")
                    .font(.system(size: 14))
                    .foregroundColor(.Text.secondary)
                    .padding(.top, 20)

                summaryContent
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
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
            } else if model.summary.isEmpty {
                Text("Summary not available")
                    .foregroundColor(.Text.secondary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
            } else {
                Text(model.summary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                    .foregroundColor(.Text.primary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
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
}
