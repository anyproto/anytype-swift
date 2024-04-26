import AVKit

final class LoopingPlayerUIView: UIView, SceneStateListener {
    
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private let player = AVQueuePlayer()
    private let sceneStateNotifier = ServiceLocator.shared.sceneStateNotifier()
    
    init(url: URL) {
        super.init(frame: .zero)
        
        sceneStateNotifier.addListener(self)
        setup(with: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(with url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    // MARK: - SceneStateListener
    
    func willEnterForeground() {
        player.play()
    }
    
    func didEnterBackground() {}
}
