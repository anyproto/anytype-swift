//
//  AudioBlockContentView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import Services
import AnytypeCore


final class AudioBlockContentView: UIView, BlockContentView {
    
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    
    private var document: BaseDocumentProtocol?
    private var targetObjectId: String?
    private var cancellable: AnyCancellable?
    
    // MARK: - Views
    let audioPlayerView = AudioPlayerView()
    let backgroundView = UIView()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupLayout()
    }

    func update(with configuration: AudioBlockContentConfiguration) {
        apply(configuration: configuration)
    }

    private func setup() {
        backgroundColor = .clear
    }

    private func setupLayout() {
        addSubview(backgroundView) {
            $0.pinToSuperview(insets: Layout.blockBackgroundPadding)
        }

        addSubview(audioPlayerView) {
            $0.pinToSuperview()
        }
    }

    private func apply(configuration: AudioBlockContentConfiguration) {
        
        if document?.objectId != configuration.documentId {
             document = documentService.document(objectId: configuration.documentId)
        }
        
        if targetObjectId != configuration.file.metadata.targetObjectId {
            targetObjectId = configuration.file.metadata.targetObjectId
            cancellable = document?.targetDetailsPublisher(targetObjectId: configuration.file.metadata.targetObjectId)
                .sinkOnMain { [weak self] fileDetails in
                    self?.audioPlayerView.setDelegate(delegate: configuration.audioPlayerViewDelegate)
                    self?.audioPlayerView.updateAudioInformation(delegate: configuration.audioPlayerViewDelegate)
                    self?.audioPlayerView.trackNameLabel.setText(fileDetails.fileName)
                }
        }
    }
}

private extension AudioBlockContentView {
    enum Layout {
        static let blockBackgroundPadding: UIEdgeInsets = .init(top: 10, left: 0, bottom: 10, right: 0)
    }
}
