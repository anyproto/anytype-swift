import SwiftUI
import Services

struct ChatInput: View {

    @Environment(\.widgetsAnimationNamespace) private var widgetsNamespace

    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let hasAdditionalData: Bool
    let disableSendButton: Bool
    let disableAddButton: Bool
    let sendButtonIsLoading: Bool
    let createObjectTypes: [ObjectType]
    let spaceUxType: SpaceUxType
    let onTapAddObject: () -> Void
    let onTapAddMedia: () -> Void
    let onTapAddFiles: () -> Void
    let onTapCamera: () -> Void
    let onTapCreateObject: (_ type: ObjectType) -> Void
    let onTapBurger: () -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    let onLinkAdded: (_ url: URL) -> Void
    let onPasteAttachmentsFromBuffer: ((_ items: [NSItemProvider]) -> Void)
    
    private let mainObjectTypeToCreateKey = ObjectTypeUniqueKey.page
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            burgerButton
            input
            plusButton
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var burgerButton: some View {
        if let widgetsNamespace, #available(iOS 26.0, *) {
            burgerButtonView.matchedTransitionSource(id: "widgetsOverlay", in: widgetsNamespace)
        } else {
            burgerButtonView
        }
    }
    
    @ViewBuilder
    private var burgerButtonView: some View {
        Button {
            onTapBurger()
        } label: {
            Image(asset: .X24.burger)
                .renderingMode(.template)
                .navPanelDynamicForegroundStyle()
                .padding(4)
        }
        .frame(width: 40, height: 40)
        .background(Color.Shape.tertiary)
        .clipShape(Circle())
    }

    private var plusButton: some View {
        Menu {
            Button { onTapAddMedia() } label: {
                Label(Loc.photos, systemImage: "photo")
            }
            
            Button { onTapCamera() } label: {
                Label(Loc.camera, systemImage: "camera")
            }
            
            Button { onTapAddFiles() } label: {
                Label(Loc.files, systemImage: "doc")
            }
            
            Button { onTapAddObject() } label: {
                Label(Loc.attachObject, systemImage: "link")
            }
            
            if let objectType = mainObjectTypeToCreate() {
                Button {
                    onTapCreateObject(objectType)
                } label: {
                    Label(Loc.newPage, systemImage: "doc.plaintext")
                }
            }
            
            Divider()
            
            Menu {
                ForEach(moreObjectTypesToCreate()) { type in
                    Button {
                        onTapCreateObject(type)
                    } label: {
                        Text(type.displayName)
                    }
                }
            } label: {
                Text(Loc.more)
            }
        } label: {
            Image(asset: .X24.plus)
                .navPanelDynamicForegroundStyle()
                .padding(4)
        }
        .frame(width: 40, height: 40)
        .background(Color.Shape.tertiary)
        .clipShape(Circle())
        .menuOrder(.fixed)
        .disabled(disableAddButton)
    }

    private var input: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if text.string.isEmpty {
                    Text(spaceUxType.isStream ? Loc.Message.Input.Stream.emptyPlaceholder : Loc.Message.Input.Chat.emptyPlaceholder)
                        .anytypeStyle(.chatText)
                        .foregroundStyle(Color.Text.tertiary)
                        .padding(.top, 9)
                        .allowsHitTesting(false)
                        .lineLimit(1)
                }
                ChatTextView(
                    text: $text,
                    editing: $editing,
                    mention: $mention,
                    minHeight: 40,
                    maxHeight: 156,
                    linkTo: onTapLinkTo,
                    linkParsed: onLinkAdded,
                    pasteAttachmentsFromBuffer: onPasteAttachmentsFromBuffer
                )
            }
            if hasAdditionalData || !text.string.isEmpty {
                sendButton
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 28))
    }
    
    @ViewBuilder
    private var sendButton: some View {
        Button {
            onTapSend()
        } label: {
            if sendButtonIsLoading {
                CircleLoadingView()
                    .frame(width: 32, height: 32)
            } else {
                Image(asset: .Chat.SendMessage.active)
            }
        }
        .buttonStyle(StandardPlainButtonStyle())
        .disabled(disableSendButton)
        .frame(width: 32, height: 40)
        // Store in layout for calculate correct textview height when user paste in empty textview
        .opacity(hasAdditionalData || !text.string.isEmpty ? 1 : 0)
    }
}

extension ChatInput {
    
    private func mainObjectTypeToCreate() -> ObjectType? {
        createObjectTypes.first { $0.uniqueKey == mainObjectTypeToCreateKey }
    }
    
    private func moreObjectTypesToCreate() -> [ObjectType] {
        createObjectTypes.filter { $0.uniqueKey != mainObjectTypeToCreateKey }
    }
}
