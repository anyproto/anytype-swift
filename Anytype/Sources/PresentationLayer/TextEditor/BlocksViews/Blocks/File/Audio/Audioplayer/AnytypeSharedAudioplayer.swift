import AVFoundation


@MainActor
final class AnytypeSharedAudioplayer {
    static let sharedInstance = AnytypeSharedAudioplayer()

    private let anytypeAudioplayer: AnytypeAudioPlayer
    private(set) var currentAudioId: String = ""

    // MARK: - Lifecycle

    private init() {
        self.anytypeAudioplayer = AnytypeAudioPlayer()
    }

    // MARK: - Public methods

    func isPlaying(audioId: String) -> Bool {
        currentAudioId == audioId && anytypeAudioplayer.isPlaying
    }

    func pause(audioId: String) {
        guard currentAudioId == audioId else {
            return
        }
        pauseCurrentAudio()
    }
    
    func pauseCurrentAudio() {
        anytypeAudioplayer.pause()
    }

    func setTrackTime(audioId: String, value: Double, completion: @escaping @MainActor () -> Void) {
        guard currentAudioId == audioId else {
            completion()
            return
        }
        anytypeAudioplayer.setTrackTime(value: value, completion: completion)
    }

    func play(audioId: String, name: String, playerItem: AVPlayerItem?, seekTime: Double, delegate: some AnytypeAudioPlayerDelegate) {
        if currentAudioId != audioId {
            // pause current audio item
            anytypeAudioplayer.pause()

            // set new audio item
            anytypeAudioplayer.setAudio(playerItem: playerItem, name: name, delegate: delegate)
            currentAudioId = audioId
        }
        anytypeAudioplayer.setTrackTime(value: seekTime, completion: { [weak self] in
            self?.anytypeAudioplayer.play()
        })
    }

    func updateDelegate(audioId: String, delegate: some AnytypeAudioPlayerDelegate) {
        guard currentAudioId == audioId, anytypeAudioplayer.delegate !== delegate  else { return }
        anytypeAudioplayer.delegate = delegate
    }
}
