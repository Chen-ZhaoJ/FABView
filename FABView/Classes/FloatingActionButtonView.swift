import UIKit

public final class FloatingActionButtonView: UIView{
    public enum FabDirection {
        case left
        case right
    }
    struct ViewModel{
        var fabDirection: FabDirection = .left
        var collapseImage: UIImage = UIImage()
        var expandImage: UIImage = UIImage()
        var btnLeftOrRightSpace: CGFloat = 30
        var btnBottom: CGFloat = -40
        var buttonSize: CGFloat = 50
        var fabExpandColor: UIColor = UIColor.black
        var fabCollapseColor: UIColor = UIColor.yellow
        var lblTextSize: Double = 20
        var lblTextColor: UIColor = UIColor.systemYellow
        var maskAlpha: CGFloat = 0.5
        var maskColor: UIColor = UIColor.black
        var intervalOfButtons: CGFloat = 5
    }
    private var vm = ViewModel()
    private var isExpand: Bool = false
    private var views: [UIView] = []
    private var btns: [UIButton] = []
    private var lbls: [UILabel] = []
    private var bottomAnchors: [NSLayoutConstraint] = []
    private let customMaskView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(fabDirection: FabDirection = .left, collapseImage: UIImage, expandImage: UIImage, btnLeftOrRightSpace: CGFloat = 30, btnBottom: CGFloat = -40, buttonSize: CGFloat = 50, fabCollapseColor: UIColor = UIColor.yellow, fabExpandColor: UIColor = UIColor.black, intervalOfButtons: CGFloat = 5, lblTextSize: Double = 20, lblTextColor: UIColor = UIColor.systemYellow, maskAlpha: CGFloat = 0.5, maskColor: UIColor = UIColor.black){
        self.init()
        initialMask()
        vm.fabDirection = fabDirection
        vm.collapseImage = collapseImage
        vm.expandImage = expandImage
        vm.btnLeftOrRightSpace = btnLeftOrRightSpace
        vm.btnBottom = btnBottom
        vm.buttonSize = buttonSize
        vm.fabCollapseColor = fabCollapseColor
        vm.fabExpandColor = fabExpandColor
        vm.intervalOfButtons = intervalOfButtons
        vm.lblTextSize = lblTextSize
        vm.lblTextColor = lblTextColor
        vm.maskAlpha = maskAlpha
        vm.maskColor = maskColor
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !btns[0].frame.contains(location) && isExpand == true else { return } //位置不在FAB且FAB為展開時
        clickFAB(btns[0])
    }
    
    public func createFAB(image: UIImage, title: String? = nil, target: Selector? = nil, atVC: Any? = nil){
        let index = views.count
        createView(index: index)
        createLabel(index: index, title: title ?? "")
        createButton(image: image, index: index, target: target, atVC: atVC)
    }
        
    public func collapseFAB(){
        guard isExpand == true else { return }
        clickFAB(btns[0])
    }
    
    private func createView(index: Int){
        let myView: UIView = UIView()
        views.insert(myView, at: index)
        let vi = views[index]
        
        if index != 0 {
            insertSubview(vi, belowSubview: views[index-1])
        }else{
            insertSubview(vi, at: 1)
        }
        vi.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
        bottomAnchors.insert(bottomConstraint, at: index)
        bottomAnchors[index] = vi.bottomAnchor.constraint(equalTo: bottomAnchor, constant: vm.btnBottom)
        NSLayoutConstraint.activate([vi.widthAnchor.constraint(equalTo: widthAnchor, constant: 0),
                                     vi.heightAnchor.constraint(equalToConstant: vm.buttonSize),
                                     vi.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     bottomAnchors[index]])
    }
    
    private func createButton(image: UIImage, index: Int, target: Selector?, atVC: Any?){
        let button: UIButton = UIButton()
        btns.insert(button, at: index)
        let bi = btns[index]
        let vi = views[index]
        bi.setImage(image, for: .normal)
        bi.layer.cornerRadius = 25
        bi.backgroundColor = vm.fabCollapseColor
        
        vi.addSubview(bi)
        bi.translatesAutoresizingMaskIntoConstraints = false
        var lead: CGFloat = 0
        if vm.fabDirection == .left{
            lead = vm.btnLeftOrRightSpace
        }else{
            lead = UIScreen.main.bounds.size.width-vm.btnLeftOrRightSpace-vm.buttonSize
        }
        NSLayoutConstraint.activate([bi.widthAnchor.constraint(equalToConstant: vm.buttonSize),
                                     bi.heightAnchor.constraint(equalToConstant: vm.buttonSize),
                                     bi.leadingAnchor.constraint(equalTo: vi.leadingAnchor, constant: lead),
                                     bi.bottomAnchor.constraint(equalTo: vi.bottomAnchor, constant: 0)])
        if index == 0{
            btns[0].addTarget(self, action: #selector(clickFAB(_:)), for: UIControl.Event.touchUpInside)
        }
        guard target != nil else { return }
        btns[index].addTarget(atVC, action: target ?? Selector(String()), for: UIControl.Event.touchUpInside)
    }
    
    private func createLabel(index: Int, title: String){
        let label: UILabel = UILabel()
        lbls.insert(label, at: index)
        let li = lbls[index]
        let vi = views[index]
        li.text = title
        li.textColor = vm.lblTextColor
        li.font = UIFont.systemFont(ofSize: vm.lblTextSize)
        li.isHidden = true
        
        vi.addSubview(li)
        li.translatesAutoresizingMaskIntoConstraints = false
        var lblLeading: CGFloat = 55
        if vm.fabDirection == .left{
            lblLeading = vm.buttonSize+vm.btnLeftOrRightSpace+5
            li.textAlignment = .left
        }else{
            lblLeading = -5-vm.btnLeftOrRightSpace
            li.textAlignment = .right
        }
        NSLayoutConstraint.activate([li.centerYAnchor.constraint(equalTo: vi.centerYAnchor, constant: 0),
                                     li.widthAnchor.constraint(equalTo: vi.widthAnchor, constant: -vm.buttonSize),
                                     li.leadingAnchor.constraint(equalTo: vi.leadingAnchor, constant: lblLeading)])
    }
    
    @IBAction private func clickFAB (_ sender: UIButton){
        if sender.isSelected == false && sender == btns[0] { //即將展開
            customMaskView.isHidden=false //顯示customMaskView
            animationRotate(duration: 0.3, toValue: Double.pi, repeatCount: 1, btn:btns[0]) //順時針轉
            btns[0].setImage(vm.expandImage, for: .normal) //按鈕樣式改展開時
            btns[0].backgroundColor = vm.fabExpandColor

            for i in 1 ..< views.count{ //顯示字、把button展開
                lbls[i].isHidden = false
                bottomAnchors[i].constant = bottomAnchors[i].constant-CGFloat(i)*(btns[0].frame.width+vm.intervalOfButtons)
                let from = [views[0].frame.midX,views[0].frame.midY]
                let to = [views[0].frame.midX,views[0].frame.midY-CGFloat(i)*(btns[0].frame.width+vm.intervalOfButtons)]
                animationPosition(duration: 0.3, fromValue: from, toValue: to, index: i)
            }
        }else{ //即將收回
            btns[0].setImage(vm.collapseImage, for: .normal) //按鈕樣式改收回時
            btns[0].backgroundColor = vm.fabCollapseColor
            animationRotate(duration: 0.3, toValue: 0, repeatCount: -1, btn:btns[0]) //逆時針轉
            customMaskView.isHidden=true //隱藏customMaskView

            for i in 1 ..< views.count{ //把button收回、隱藏字
                bottomAnchors[i].constant = vm.btnBottom
                let from = [views[0].frame.midX,views[0].frame.midY-CGFloat(i)*(btns[0].frame.width+vm.intervalOfButtons)]
                let to = [views[0].frame.midX,views[0].frame.midY]
                animationPosition(duration: 0.3, fromValue: from, toValue: to, index: i)
                lbls[i].isHidden = true
            }
        }
        btns[0].isSelected = !btns[0].isSelected //切換FAB的選中狀態
        isExpand = !isExpand
    }
    
    private func initialMask(){
        customMaskView.backgroundColor = vm.maskColor.withAlphaComponent(vm.maskAlpha)
        customMaskView.isHidden = true
        insertSubview(customMaskView, at: 0)
        customMaskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([customMaskView.widthAnchor.constraint(equalTo: widthAnchor),
                                     customMaskView.heightAnchor.constraint(equalTo: heightAnchor),
                                     customMaskView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     customMaskView.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
    
    private func animationRotate(duration: Double, toValue: Double, repeatCount: Float, btn: UIButton){ //旋轉動畫
        let animRotate = CABasicAnimation(keyPath: "transform.rotation")
        animRotate.duration = duration //動畫速度
        animRotate.isRemovedOnCompletion = false //結束時不回復原樣
        animRotate.fillMode = CAMediaTimingFillMode.forwards //讓layer停在toValue
        animRotate.toValue = toValue //設定動畫結束值
        animRotate.repeatCount = repeatCount //旋轉次數（正1為順時針一圈，負為逆時針）
        btn.imageView?.layer.add(animRotate, forKey: nil)
    }
    
    private func animationPosition(duration: Double, fromValue: [CGFloat], toValue: [CGFloat], index: Int){ //位移動畫
        let animPosition = CABasicAnimation(keyPath: "position")
        animPosition.duration = duration
        animPosition.isRemovedOnCompletion = false
        animPosition.fillMode = CAMediaTimingFillMode.forwards
        animPosition.fromValue = fromValue
        animPosition.toValue = toValue
        views[index].layer.add(animPosition, forKey: nil)
    }
}
