import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var timerForLeftLayer = Timer()
    
    var leftLayerX:CGFloat = 0
    var leftLayerY:CGFloat = 0
    
    var rightLayerX:CGFloat = 1
    var rightLayerY:CGFloat = 1
    
    var step:CGFloat = 0.01
    
    let addToRightLayer:CGFloat = 0.05
    let penalty:CGFloat = 0.02
    
    let cardView = UIView()
    
    let centerView = UIView()
    
    let leftProgressView = UIView()
    let rightProgressView = UIView()
    
    let leftLayer = CAGradientLayer()
    let rightLayer = CAGradientLayer()
    
    let leftLayerAnimation = CABasicAnimation()
    let rightLayerAnimtion = CABasicAnimation()
    
    let viewsArray:[UIView] = [UIView(), UIView(), UIView(), UIView(), UIView(), UIView()]
    
    let colorsArray:[UIColor] = [UIColor(red: 255/255.0, green: 20/255.0, blue: 147/255.0, alpha: 1),
                                 UIColor(red: 15/255.0, green: 82/255.0, blue: 186/255.0, alpha: 1),
                                 UIColor(red: 255/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1),
                                 UIColor(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1),
                                 UIColor(red: 127/255.0, green: 255/255.0, blue: 212/255.0, alpha: 1),
                                 UIColor(red: 210/255.0, green: 31/255.0, blue: 60/255.0, alpha: 1)]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Main Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.backgroundColor = .black
        createScene()
    }
    
    //MARK: - Flow Functions
    
    @objc func checkColor(gestureRecogniser: MyTapGestureRecogniser) {
        if gestureRecogniser.color == cardView.backgroundColor {
            print("молодцом")
            self.moveLeftLayerUp()
            self.animationActionsForRightLayer()
        } else {
            self.addPenaltyToLeftLayer()
            print("ну бывает")
        }
        changeColorOfTheCard()
    }
    
    func createScene() {
        addCenterView()
        addKeyPads()
        createACardInTheCenterOfView()
    }
    
    func changeColorOfTheCard() {
        let randomIndex = Int.random(in: 0...5)
        cardView.backgroundColor = colorsArray[randomIndex]
    }
    
    func addCenterView() {
        centerView.frame.size = CGSize(width: self.view.frame.size.width - self.view.frame.size.width/3, height: self.view.frame.size.height - 250)
        centerView.center = containerView.center
        centerView.layer.cornerRadius = 80
        centerView.layer.borderWidth = 10
        centerView.layer.masksToBounds = true
        centerView.clipsToBounds = true
        containerView.addSubview(centerView)
    }
    
    func addKeyPads() {
        var loaclColorsArray = colorsArray
        viewsArray[0].frame = CGRect(x: 0,
                                     y: 0,
                                     width: centerView.frame.size.width/2,
                                     height: centerView.frame.size.height/9 * 2.5)
        viewsArray[1].frame = CGRect(x: 0,
                                     y: viewsArray[0].frame.size.height,
                                     width: centerView.frame.size.width/2,
                                     height: centerView.frame.size.height/9 * 4)
        viewsArray[2].frame =  CGRect(x: 0,
                                      y: 0 + viewsArray[0].frame.size.height + viewsArray[1].frame.size.height,
                                      width: centerView.frame.size.width/2,
                                      height: centerView.frame.size.height/9 * 2.5)
        
        viewsArray[3].frame = CGRect(x: centerView.frame.size.width/2,
                                     y: 0,
                                     width: centerView.frame.size.width/2,
                                     height: centerView.frame.size.height/9 * 2.5)
        viewsArray[4].frame = CGRect(x: centerView.frame.size.width/2,
                                     y: viewsArray[0].frame.size.height,
                                     width: centerView.frame.size.width/2,
                                     height: centerView.frame.size.height/9 * 4)
        viewsArray[5].frame =  CGRect(x: centerView.frame.size.width/2,
                                      y: 0 + viewsArray[0].frame.size.height + viewsArray[1].frame.size.height,
                                      width: centerView.frame.size.width/2,
                                      height: centerView.frame.size.height/9 * 2.5)
        
        for view in viewsArray {
            view.backgroundColor = loaclColorsArray.first
            view.isUserInteractionEnabled = true
            view.layer.borderWidth = 10
            view.layer.borderColor = UIColor.black.cgColor
            addTapToViews(view: view)
            
            loaclColorsArray.removeFirst()
        
            centerView.addSubview(view)
        }
        addProgressViews()
    }
    
    func addTapToViews(view: UIView) {
        let tap = MyTapGestureRecogniser(target: self, action: #selector(checkColor))
        tap.color = view.backgroundColor
        view.addGestureRecognizer(tap)
    }
    
    func addProgressViews() {
        leftProgressView.frame = CGRect(x: containerView.frame.origin.x + 20, y: containerView.frame.origin.y + 100, width: 40, height: containerView.frame.size.height - 200)
        containerView.addSubview(leftProgressView)
        
        rightProgressView.frame = CGRect(x: containerView.frame.size.width - leftProgressView.frame.size.width - 20, y: containerView.frame.origin.y + 100, width: 40, height: containerView.frame.size.height - 200)
        containerView.addSubview(rightProgressView)
        
        leftLayer.frame = leftProgressView.bounds
        leftLayer.cornerRadius = 20
        leftLayer.locations = [0, 0]
        leftLayer.colors = [UIColor(red: 153/255.0, green: 87/255.0, blue: 205/255.0, alpha: 1).cgColor, UIColor.black.cgColor]
        leftProgressView.layer.addSublayer(leftLayer)
        
        rightLayer.frame = rightProgressView.bounds
        rightLayer.cornerRadius = 20
        rightLayer.locations = [1, 1]
        rightLayer.colors = [UIColor.black.cgColor, UIColor(red: 228/255.0, green: 114/255.0, blue: 121/255.0, alpha: 1).cgColor]
        rightProgressView.layer.addSublayer(rightLayer)
        
        animateLeftLayer()
    }
    
    func animateLeftLayer() {
        timerForLeftLayer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (_) in
            self.animationActionsForLeftLayer()
        })
    }
    
    func animationActionsForLeftLayer() {
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
            self.leftLayerAnimation.duration = 0.2
            self.leftLayerY += self.step
            self.leftLayerAnimation.toValue = [self.leftLayerX, self.leftLayerY]
            self.leftLayerAnimation.isRemovedOnCompletion = false
            self.leftLayer.add(self.leftLayerAnimation, forKey: "locationsChange")
            self.leftLayer.locations = [self.leftLayerX, self.leftLayerY] as [NSNumber]
        })
        checkLeftLayer()
    }
    
    func createACardInTheCenterOfView() {
        cardView.frame.size = CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.height - 400)
        cardView.layer.cornerRadius = 40
        cardView.layer.borderWidth = 20
        cardView.layer.borderColor = UIColor.black.cgColor
        cardView.center = centerView.center
        changeColorOfTheCard()
        view.addSubview(cardView)
    }
    
    func moveLeftLayerUp() {
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            self.leftLayerAnimation.duration = 0.05
            self.leftLayerY -= 0.05
            self.leftLayerAnimation.toValue = [self.leftLayerX, self.leftLayerY]
            self.leftLayerAnimation.isRemovedOnCompletion = false
            self.leftLayer.add(self.leftLayerAnimation, forKey: "locationsChange")
            self.leftLayer.locations = [self.leftLayerX, self.leftLayerY] as [NSNumber]
        })
    }
    
    func addPenaltyToLeftLayer() {
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            self.leftLayerAnimation.duration = 0.05
            self.leftLayerY += self.penalty
            self.leftLayerAnimation.toValue = [self.leftLayerX, self.leftLayerY]
            self.leftLayerAnimation.isRemovedOnCompletion = false
            self.leftLayer.add(self.leftLayerAnimation, forKey: "locationsChange")
            self.leftLayer.locations = [self.leftLayerX, self.leftLayerY] as [NSNumber]
        })
    }
    
    func animationActionsForRightLayer() {
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
            self.rightLayerAnimtion.duration = 0.1
            self.rightLayerX -= self.addToRightLayer
            self.rightLayerAnimtion.toValue = [self.rightLayerX, self.rightLayerY]
            self.rightLayerAnimtion.isRemovedOnCompletion = false
            self.rightLayer.add(self.rightLayerAnimtion, forKey: "locationsChange")
            self.rightLayer.locations = [self.rightLayerX, self.rightLayerY] as [NSNumber]
        })
        checkRightLayer()
    }
    
    func checkRightLayer() {
        if rightLayerX <= 0 {
            self.rightLayerX = 1
            self.step += 0.01
        }
    }
    
    func checkLeftLayer() {
        if leftLayerY >= 1 {
            timerForLeftLayer.invalidate()
            showAlert()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "Game Over", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Restart", style: .default) { (_) in
            self.resetGame()
            self.createScene()
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetGame() {
        centerView.removeFromSuperview()
        rightProgressView.removeFromSuperview()
        leftProgressView.removeFromSuperview()
        cardView.removeFromSuperview()
        
        step = 0.01
        leftLayerY = 0
        rightLayerX = 1
    }

}

