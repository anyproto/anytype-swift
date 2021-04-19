import UIKit

class OldHomeCollectionViewPlusCell: UICollectionViewCell {
    static let reuseIdentifer = "OldHomeCollectionViewPlusCellReuseIdentifier"
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        layer.cornerRadius = 8.0
        layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        layer.borderWidth = 1.0
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        imageView.image = #imageLiteral(resourceName: "plus").withTintColor(.white)
    }
}
