
import Foundation
import UIKit
import Kingfisher

final class GTAModes_GameModesTableViewCell: UITableViewCell, GTAModes_Reusable {
    
    public var shareAction: (() -> Void)?
    public var downloadAction: (() -> Void)?
    
    private var kingfisherManager: KingfisherManager
    private var downloadTask: DownloadTask?
    private var bgContainerView = UIView()
    private let containerView = UIView()
    private let buttonsContainerView = UIView()
    private let titleLabel = UILabel()
    private let downloadTitleLabel = UILabel()
    private let shareTitleLabel = UILabel()
    
    private let modeImage: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    private let descriprionLabel = UILabel()
    private let shareButtonView = UIView()
    private let downloadButtonView = UIView()
    private let stackView = UIStackView()
    
    private var imageOptions: KingfisherOptionsInfo = [
        .processor(ResizingImageProcessor(
            referenceSize: CGSize(
                width: UIScreen.main.bounds.width - 48.0,
                height: UIDevice.current.userInterfaceIdiom == .pad ? 400.0 : 115
            ),
            mode: .aspectFill
        )
        )
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.kingfisherManager = KingfisherManager.shared
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        gta_setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        descriprionLabel.text = ""
        modeImage.image = nil
        downloadTask?.cancel()
    }
    
    public func gameMode_configure_cell(_ value: ModItem, isLoaded: Bool) {
        titleLabel.font = UIFont(name: "Gilroy-Semibold", size: 15)
        titleLabel.textColor = .white
        titleLabel.text = value.title
        descriprionLabel.font = UIFont(name: "Gilroy-Regular", size: 15)
        descriprionLabel.textColor = .white
        descriprionLabel.text = value.description
        
        downloadButtonView.backgroundColor = isLoaded ? UIColor(named: "greenColor")?.withAlphaComponent(1.0) : UIColor(named: "ButtonColor")?.withAlphaComponent(1.0)
        downloadTitleLabel.font = UIFont(name: "Gilroy-Semibold", size: 20)
        downloadTitleLabel.textColor = .white
        downloadTitleLabel.text = isLoaded ? "Downloaded" : "Download"
        
        gta_setImageMod(value)
    }
    
    private func gta_setImageMod(_ mode: ModItem) {
        if ImageCache.default.isCached(forKey: mode.imagePath) {
            gta_setImage(with: mode.imagePath)
        } else {
            guard let imageModUrl = URL(string: mode.imagePath) else { return }
            
            downloadTask = self.kingfisherManager.retrieveImage(
                with: imageModUrl, options: imageOptions) { [weak self] result in
                    guard case .success(let value) = result  else { return }
                    guard let self = self else { return }
                    
                    if !self.gta_isLocalCachePhoto(with: mode.imagePath) {
                        self.gta_saveImage(
                            image: value.image,
                            cacheKey: imageModUrl.absoluteString) { [weak self] in
                                self?.gta_setImage(with: mode.imagePath)
                            }
                    } else {
                        self.gta_setImage(with: mode.imagePath)
                    }
                }
        }
    }
    
    private func gta_setupLayout() {
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.gta_layout {
            $0.top.equal(to: contentView.topAnchor)
            $0.bottom.equal(to: contentView.bottomAnchor, offsetBy: -6.0)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: 20.0)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -20.0)
        }
        containerView.withCornerRadius(20.0)
        containerView.backgroundColor = .clear
        
        containerView.addSubview(bgContainerView)
        bgContainerView.gta_layout {
            $0.top.equal(to: containerView.topAnchor)
            $0.bottom.equal(to: containerView.bottomAnchor, offsetBy: -70.0)
            $0.leading.equal(to: containerView.leadingAnchor, offsetBy: 0.0)
            $0.trailing.equal(to: containerView.trailingAnchor, offsetBy: 0.0)
        }
        bgContainerView.withCornerRadius(20.0)
        bgContainerView.backgroundColor = UIColor(named: "CheckCell")?.withAlphaComponent(1.0)
    
        containerView.addSubview(titleLabel)
        titleLabel.gta_layout {
            $0.top.equal(to: containerView.topAnchor, offsetBy: 20.0)
            $0.leading.equal(to: containerView.leadingAnchor, offsetBy: 15.0)
            $0.trailing.equal(to: containerView.trailingAnchor, offsetBy: -15.0)
        }
        titleLabel.numberOfLines = 0
        
        containerView.addSubview(modeImage)
        
        modeImage.gta_layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 8.0)
            $0.leading.equal(to: containerView.leadingAnchor, offsetBy: 8.0)
            $0.trailing.equal(to: containerView.trailingAnchor, offsetBy: -8.0)
            $0.height.equal(to: UIDevice.current.userInterfaceIdiom == .pad ? 400.0 : 218.0)
        }
        
        
        containerView.addSubview(descriprionLabel)
        descriprionLabel.gta_layout {
            $0.top.equal(to: modeImage.bottomAnchor, offsetBy: 8.0)
            $0.leading.equal(to: containerView.leadingAnchor, offsetBy: 15.0)
            $0.trailing.equal(to: containerView.trailingAnchor, offsetBy: -15.0)
        }
        descriprionLabel.numberOfLines = 0
        
        containerView.addSubview(stackView)
        stackView.gta_layout {
            $0.height.equal(to: 60)
            $0.leading.equal(to: containerView.leadingAnchor, offsetBy: 0.0)
            $0.trailing.equal(to: containerView.trailingAnchor, offsetBy: 0.0)
            $0.top.equal(to: descriprionLabel.bottomAnchor, offsetBy: 30.0)
            $0.bottom.equal(to: containerView.bottomAnchor, offsetBy:  0.0)
        }
        
        gta_configureStackView(stackView)
        shareButtonView.backgroundColor = UIColor(named: "ButtonColor")?.withAlphaComponent(1.0)
        downloadButtonView.backgroundColor = UIColor(named: "ButtonColor")?.withAlphaComponent(1.0)
        shareButtonView.withCornerRadius(10.0)
        shareButtonView.dropShadow()
        downloadButtonView.withCornerRadius(10.0)
        downloadButtonView.dropShadow()
        
        let shareView = configureButtonView(title: "Share", imageName: "share-2", isShare: true)
        shareButtonView.addSubview(shareView)
        shareView.gta_layout {
            $0.width.equal(to: shareButtonView.widthAnchor)
            $0.centerX.equal(to: shareButtonView.centerXAnchor)
            $0.centerY.equal(to: shareButtonView.centerYAnchor)
        }
        
        let downloadView = configureButtonView(title: "Download", imageName: "download-cloud", isShare: false)
        downloadButtonView.addSubview(downloadView)
        downloadView.gta_layout {
            $0.width.equal(to: downloadButtonView.widthAnchor)
            $0.centerX.equal(to: downloadButtonView.centerXAnchor)
            $0.centerY.equal(to: downloadButtonView.centerYAnchor)
        }
        
        shareButtonView.gta_layout {
            $0.height.equal(to: 42.0)
        }
        downloadButtonView.gta_layout {
            $0.height.equal(to: 42.0)
        }
        let shareGestrure = UITapGestureRecognizer(target: self, action: #selector(gta_shareActionProceed))
        shareButtonView.addGestureRecognizer(shareGestrure)
        
        
        let downloadGestrure = UITapGestureRecognizer(target: self, action: #selector(gta_downloadActionProceed))
        downloadButtonView.addGestureRecognizer(downloadGestrure)
        
        stackView.addArrangedSubview(shareButtonView)
        stackView.addArrangedSubview(downloadButtonView)
        containerView.layoutIfNeeded()
    }
    
    func gta_configureStackView(_ stackView: UIStackView) {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .center
    }
    
    func configureButtonView(title: String, imageName: String, isShare: Bool) -> UIView {
        let buttonView = UIView()
        let titleLabel = isShare ? shareTitleLabel : downloadTitleLabel
        let imageView = UIImageView()
        buttonView.addSubview(imageView)
        buttonView.addSubview(titleLabel)
        titleLabel.dropShadow(color: .black, offSet: CGSize(width: 1.0, height: 1.0))
        titleLabel.gta_layout {
            $0.centerY.equal(to: buttonView.centerYAnchor)
            if isShare {
                $0.trailing.equal(to: buttonView.trailingAnchor, offsetBy: -10)
            } else {
                $0.leading.equal(to: buttonView.leadingAnchor, offsetBy: 10)
            }
        }
        
        imageView.gta_layout {
            $0.height.equal(to: 18.0)
            $0.width.equal(to: 18.0)
            $0.centerY.equal(to: buttonView.centerYAnchor)
            if isShare {
                $0.leading.equal(to: buttonView.leadingAnchor, offsetBy: 10)
            }else{
                $0.trailing.equal(to: buttonView.trailingAnchor, offsetBy: -10)
            }
        }
        
        titleLabel.font = UIFont(name: "Gilroy-Semibold", size: 20)
        titleLabel.textColor = .white
        titleLabel.text = title
        
        imageView.image = UIImage(named: imageName)
        
        return buttonView
    }
    
    @objc func gta_shareActionProceed() {
        shareAction?()
    }
    
    @objc func gta_downloadActionProceed() {
        downloadAction?()
    }
    
    private func gta_isLocalCachePhoto(with path: String?) -> Bool {
        guard let localPath = path, let localUrl = URL(string: localPath) else { return false }
        
        return ImageCache.default.isCached(forKey: localUrl.absoluteString)
    }
    
    private func gta_saveImage(image: UIImage, cacheKey: String, completion: (() -> Void)? = nil) {
        ImageCache.default.store(image, forKey: cacheKey, options: KingfisherParsedOptionsInfo(nil)) { _ in
            completion?()
        }
    }
    
    private func gta_setImage(with urlPath: String, completionHandler: (() -> Void)? = nil) {
        guard let urlImage = URL(string: urlPath) else {
            completionHandler?()
            return
        }
        
        downloadTask = kingfisherManager.retrieveImage(with: urlImage, options: imageOptions) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                self.modeImage.image = value.image
            case .failure:
                self.modeImage.image = nil
            }
            
            completionHandler?()
        }
    }
}
