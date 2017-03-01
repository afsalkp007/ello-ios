////
///  ElloTabBar.swift
//

class ElloTabBar: UITabBar {
    struct Size {
        static let height = CGFloat(49)
    }

    fileprivate var redDotViews = [(Int, UIView, CGPoint)]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }

    convenience init() {
        self.init(frame: .zero)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    fileprivate func privateInit() {
        self.backgroundColor = UIColor.white
        self.isTranslucent = false
        self.isOpaque = true
        self.barTintColor = UIColor.white
        self.tintColor = UIColor.black
        self.clipsToBounds = true
        self.shadowImage = UIImage.imageWithColor(UIColor.white)
    }

    func addRedDotAtIndex(_ index: Int, margins: CGPoint = CGPoint(x: 0, y: 9)) -> UIView {
        let redDot: UIView
        if let entryIndex = (redDotViews.index { $0.0 == index }) {
            redDot = redDotViews[entryIndex].1
        }
        else {
            redDot = UIView()
            redDot.backgroundColor = UIColor.red
            redDot.isHidden = true
            let redDotEntry = (index, redDot, margins)
            redDotViews.append(redDotEntry)
            addSubview(redDot)
        }

        positionRedDot(redDot, atIndex: index, margins: margins)
        return redDot
    }

    fileprivate func tabBarFrameAtIndex(_ index: Int) -> CGRect {
        let tabBarButtons = subviews.filter {
            $0 is UIControl
        }.sorted {
            $0.frame.minX < $1.frame.minX
        }
        return tabBarButtons.safeValue(index)?.frame ?? .zero
    }

    fileprivate func positionRedDot(_ redDot: UIView, atIndex index: Int, margins: CGPoint = CGPoint(x: 0, y: 9)) {
        let radius: CGFloat = 3
        let diameter = radius * 2
        let tabBarItemFrame = tabBarFrameAtIndex(index)
        let item = items?[index]
        let imageHalfWidth: CGFloat = (item?.selectedImage?.size.width ?? 0) / 2
        let x = tabBarItemFrame.midX + imageHalfWidth + margins.x
        let frame = CGRect(x: x, y: margins.y, width: diameter, height: diameter)

        redDot.layer.cornerRadius = radius
        redDot.frame = frame
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, redDot, margins) in redDotViews {
            positionRedDot(redDot, atIndex: index, margins: margins)
        }
    }

}
