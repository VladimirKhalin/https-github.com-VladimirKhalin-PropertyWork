
//import
import Foundation
import UIKit

//class
final class GTAModes_ChecklistCell: UITableViewCell, GTAModes_Reusable {
    
    public var isCheckAction: ((Bool) -> ())?
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let switcher = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        gta_setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func gta_configure_cell(_ value: MissionItem) {
        titleLabel.font = UIFont(name: "Gilroy-Bold", size: 15)
        titleLabel.textColor = .white
        titleLabel.text = value.missionName
        switcher.isOn = value.isCheck
    }
    
    private func gta_setupLayout() {
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.gta_layout {
            $0.top.equal(to: contentView.topAnchor, offsetBy: 7.0)
            $0.bottom.equal(to: contentView.bottomAnchor, offsetBy: -7.0)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: 20.0)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -20.0)
        }
        containerView.withCornerRadius(20.0)
       // containerView.withBorder()
        containerView.dropShadow()
        containerView.backgroundColor = UIColor(named: "CheckCell")?.withAlphaComponent(0.9)
        
        
        containerView.addSubview(switcher)
        switcher.gta_layout {
            $0.trailing.equal(to: containerView.trailingAnchor, offsetBy: -16.0)
            $0.centerY.equal(to: containerView.centerYAnchor)
            $0.height.equal(to: 31.0)
            $0.width.equal(to: 51.0)
        }
        //switcher.onTintColor = .init(named: "blueLight")
        switcher.onTintColor = .green
        switcher.addTarget(self, action: #selector(gta_switchValueChanged(_:)), for: .valueChanged)
        
        containerView.addSubview(titleLabel)
        titleLabel.gta_layout {
            $0.top.equal(to: containerView.topAnchor, offsetBy: 20.0)
            $0.bottom.equal(to: containerView.bottomAnchor, offsetBy: -20.0)
            $0.leading.equal(to: containerView.leadingAnchor, offsetBy: 16.0)
            $0.trailing.lessThanOrEqual(to: switcher.leadingAnchor, offsetBy: -8.0)
            $0.centerY.equal(to: containerView.centerYAnchor)
        }
        titleLabel.numberOfLines = 0
    }
    
    @objc func gta_switchValueChanged(_ sender: UISwitch) {
        //
        isCheckAction?(sender.isOn)
        //
    }
    
}

