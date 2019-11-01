import PrebidMobile
import UIKit

class Banner: UIView {
  
  // init
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  var sizes = ["banner", "leaderboard", "mediumRectangle"]
  var isInitialized = false
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // RN props
  @objc var bannerSize: NSString = "" {
    didSet {
      print("reached bannerSize didSet")
      print(bannerSize)
      print(isInitialized)
      if !isInitialized {
        isInitialized = true
        loadView()
      } else {
        self.updateButtons()
      }
    }
  }
  
  // exposed to RN as function
  @objc var onClick: RCTDirectEventBlock?
  
  func loadView() {
    var buttons = [UIButton]()
    buttons.append(makeButton(0))
    buttons.append(makeButton(1))
    buttons.append(makeButton(2))
    
    let stack = UIStackView(arrangedSubviews: buttons)
    stack.axis = .horizontal
    stack.distribution = .equalSpacing
    stack.alignment = .fill
    stack.spacing = 5
    stack.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(stack)
  }
  
  func updateButtons() {
    let index = self.sizes.firstIndex(of: String(self.bannerSize))
    
    for v in self.subviews[0].subviews {
      v.backgroundColor = .gray
    }
    
    if index != nil {
      self.subviews[0].subviews[index!].backgroundColor = .blue
    }
    
  }
  
  func makeButton(_ sizeIndex: Int) -> UIButton {
    let size = self.sizes[sizeIndex]
    let b = UIButton.init(type: UIButton.ButtonType.system)
    b.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    b.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    b.setTitle("  \(self.sizes[sizeIndex])  ", for: .normal)
    b.tintColor = .white
    print("Size:\(size); bannerSize:\(self.bannerSize)")
    if size == String(self.bannerSize) {
      b.backgroundColor = .blue
    } else {
      b.backgroundColor = .gray
    }
    
    
    b.tag = sizeIndex
    b.addTarget(self, action: #selector(self.pressButton(_:)), for: .touchUpInside)
    return b
  }
  

  
  @objc func pressButton(_ sender: UIButton){
    print("sender")
    print(sender)
    print("bannerSize")
    print(String(sender.tag))
    for v in self.subviews[0].subviews {
      v.backgroundColor = .gray
    }
    
    self.bannerSize = self.sizes[sender.tag] as NSString
    
    let size = self.sizes[sender.tag]
    if size == String(self.bannerSize) {
      sender.backgroundColor = .blue
    }
    
    
    
    print("bannerSize")
    print("\(String(sender.tag)) : \(self.bannerSize)")

    if (onClick != nil) {
      onClick!(["bannerSize": self.bannerSize])
    }
  }
  

  
}
