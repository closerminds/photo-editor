//
//  StickersViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//  Credit https://github.com/AhmedElassuty/IOS-BottomSheet

import UIKit

class StickersViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var emojisCollectioView: UICollectionView!
    
    var emojisDelegate: EmojisCollectionViewDelegate!
    var stickersViewControllerDelegate : StickersViewControllerDelegate?
    let screenSize = UIScreen.main.bounds.size
    
    let fullView: CGFloat = 100 // remainder of screen height
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 380
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionViews()
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width,
                                        height: scrollView.frame.size.height)
        
        scrollView.isPagingEnabled = true
        
        holdView.layer.cornerRadius = 3
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(StickersViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func configureCollectionViews() {
        let emojisFrame = CGRect(x: scrollView.frame.size.width,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: view.frame.height - 40)
        
        let emojislayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        emojislayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        emojislayout.itemSize = CGSize(width: 70, height: 70)
        
        emojisCollectioView = UICollectionView(frame: emojisFrame, collectionViewLayout: emojislayout)
        emojisCollectioView.backgroundColor = .clear
        scrollView.addSubview(emojisCollectioView)
        emojisDelegate = EmojisCollectionViewDelegate()
        emojisDelegate.stickersViewControllerDelegate = stickersViewControllerDelegate
        emojisCollectioView.delegate = emojisDelegate
        emojisCollectioView.dataSource = emojisDelegate
        
        emojisCollectioView.register(
            UINib(nibName: "EmojiCollectionViewCell", bundle: Bundle(for: EmojiCollectionViewCell.self)),
            forCellWithReuseIdentifier: "EmojiCollectionViewCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let `self` = self else { return }
            let frame = self.view.frame
            let yComponent = self.partialView
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: UIScreen.main.bounds.height - self.partialView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emojisCollectioView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.width,
                                           height: view.frame.height - 40)
        
        scrollView.contentSize = CGSize(width: screenSize.width,
                                        height: scrollView.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Pan Gesture
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if y + translation.y >= fullView {
            let newMinY = y + translation.y
            self.view.frame = CGRect(x: 0, y: newMinY, width: view.frame.width, height: UIScreen.main.bounds.height - newMinY )
            self.view.layoutIfNeeded()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            //velocity is direction of gesture
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    if y + translation.y >= self.partialView  {
                        self.removeBottomSheetView()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    }
                } else {
                    if y + translation.y >= self.partialView  {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.fullView)
                        self.view.layoutIfNeeded()
                    }
                }
                
            }, completion: nil)
        }
    }
    
    func removeBottomSheetView() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
    
    
}
