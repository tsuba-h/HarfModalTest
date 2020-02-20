//
//  ViewController.swift
//  HarfModalTest
//
//  Created by 服部　翼 on 2019/09/17.
//  Copyright © 2019 服部　翼. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    private var searchVC: SearchViewController!
    @IBOutlet weak var mapView: MKMapView!
    
    private var modalViewHeight: CGFloat {
        return view.frame.height - view.safeAreaInsets.top
    }
    
    //896
    private var maxDistance: CGFloat {
        return modalViewHeight - fullpositionConstant
    }
    
    private var fullpositionConstant: CGFloat {
        return view.safeAreaInsets.top
    }
    
    private var halfPositionConstant: CGFloat {
        return maxDistance * 0.7
    }
    
    private var tipPositionConstant: CGFloat {
        return maxDistance
    }
    
    private var halfPositionFractionValue: CGFloat {
        return tipToHalfDistance / maxDistance
    }
    
    private var tipToHalfDistance: CGFloat {
        return maxDistance - halfPositionConstant
    }
    
    private var halfToFullDistance: CGFloat {
        return maxDistance - tipToHalfDistance
    }
    
    private var modalAnimator = UIViewPropertyAnimator()
    private var modalAnimatorProgress: CGFloat = 0.0 {
        didSet {
            print("modal progress \(modalAnimatorProgress)")
        }
    }
    
    private var remainigToHalfDistance: CGFloat = 0.0
    private var isRunningToHalf = false
    private var currentMode: DrawerPositionType = .half {
        didSet {
            if currentMode == .full {
                searchVC.showHeader()
            } else {
                searchVC.hideHeader()
            }
        }
    }
    
    private lazy var panGestureRecognizer: ViewPanGestureRecognizer = {
        let pan = ViewPanGestureRecognizer(target: self, action: #selector(handle(panGesture:)))
        return pan
    }()
    
    private var modalViewBottomConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //SearchViewControllerを作成
        guard let searchViewController = UIStoryboard(name: "SearchViewController", bundle: nil).instantiateInitialViewController() as? SearchViewController else {return}
        searchVC = searchViewController
        setupMap()
        //SearchViewControllerをaddChild
        self.addChild(searchVC)
        self.view.addSubview(searchVC.view)
        searchVC.didMove(toParent: self)
        
        setupModalLayout()
        
        searchVC.searchBar.delegate = self
        searchVC.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    private func setupModalLayout() {
        //オートレイアウトで設定する
        let modalView = searchVC.view!
        //https://developer.apple.com/documentation/uikit/uiview/1622572-translatesautoresizingmaskintoco
        //Autosizingのレイアウトの仕組みをAuto Layoutに変換するかどうかを設定するフラグ
        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        //SearchViewControllerのViewのBottomをhalfPositionConstantだけ離すことで半分表示される状態を作る
        modalViewBottomConstraint = modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: halfPositionConstant)
        
        modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        modalViewBottomConstraint.isActive = true
        modalView.heightAnchor.constraint(equalToConstant: modalViewHeight).isActive = true
        
        view.layoutIfNeeded()
    }
    //地図の設定
    private func setupMap() {
        let center = CLLocationCoordinate2D(latitude: 35.6585805,
                                            longitude: 139.7454329)
        let span = MKCoordinateSpan(latitudeDelta: 0.4425100023575723,
                                    longitudeDelta: 0.28543697435880233)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.showsCompass = true
        mapView.showsUserLocation = true
    }
    
    @objc private func handle(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            beganInterActionAnimator()
            activeAnimator()
        case .changed:
            // パンジェスチャーがどのぐらい動いたのか
            let translation = panGesture.translation(in: searchVC.view)
            print("translation", translation)
            // 現状のハーフモーダルビューの状態を確認
            // animatorの進捗をジェスチャーによって変更
            switch currentMode {
            case .tip:
                modalAnimator.fractionComplete = -translation.y / maxDistance + modalAnimatorProgress
            case .full:
                modalAnimator.fractionComplete = translation.y / maxDistance + modalAnimatorProgress
            case .half: fatalError()
            }
        case .ended:
            let velocity = panGesture.velocity(in: searchVC.view)
            continueInteractionAnimator(velocity: velocity)
        default: ()
        }
        
    }
    
    private func beganInterActionAnimator() {
        print(modalAnimator.isRunning)
        if !modalAnimator.isRunning {
            // animatorが実行中ではない(ポーズ状態）
            if currentMode == .half {
                // halfならtipに変更する
                currentMode = .tip
                // 制約をリセット
                modalViewBottomConstraint.constant = tipPositionConstant
                view.layoutIfNeeded()
                // 進捗状態もリセット
                modalAnimatorProgress = halfPositionFractionValue
            } else {
                modalAnimatorProgress = 0.0
            }
            // animatorを作る。プロパティを更新
            generateAnimator()
        } else if isRunningToHalf {
            // animatorがisRunning中でrunning to halfがtrue ->どういう状態？
            //　fullか、tipだけどhalfに向かっているってことか
            modalAnimator.pauseAnimation()
            isRunningToHalf.toggle()
            let currentConstantPoint: CGFloat
            switch currentMode {
            case .tip:
                currentConstantPoint = halfToFullDistance - remainigToHalfDistance * (1 - modalAnimator.fractionComplete)
                modalViewBottomConstraint.constant = tipPositionConstant
            case .full:
                currentConstantPoint = (halfToFullDistance - remainigToHalfDistance) + remainigToHalfDistance * modalAnimator.fractionComplete
                modalViewBottomConstraint.constant = fullpositionConstant
            case .half: fatalError()
            }
            // 進捗状態を作成
            // 今の制約すうw割る（modalViewHeight - 60）　高さマイナス60の値を
            modalAnimatorProgress = currentConstantPoint / maxDistance
            stopModalAnimator()
            // animatorを作り直す
            generateAnimator()
        } else {
            // animatorがランニング中で真ん中に行くわけでもない
            // animatorをポーズする
            modalAnimator.pauseAnimation()
            // アニメーターの進捗を計算
            modalAnimatorProgress = modalAnimator.isReversed ? 1 - modalAnimator.fractionComplete : modalAnimator.fractionComplete
            if modalAnimator.isReversed {
                // 反対のアニメーションになっていたら変える
                modalAnimator.isReversed.toggle()
            }
        }
    }
    
    private func generateAnimator(duration: TimeInterval = 1.0) {
        if modalAnimator.state == .active {
            stopModalAnimator()
        }
        
        modalAnimator = generateModalAnimator(duration: duration)
    }
    
    private func generateModalAnimator(duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) { [weak self] in
            // アニメーションが始まったら最初に呼ばれるクロージャー
            guard let self = self else {return}
            switch self.currentMode {
            case .tip:
                // tipの場合最終的にいくであろうfullの制約を入れる
                self.modalViewBottomConstraint.constant = self.fullpositionConstant
            case .full:
                // fullの場合も最終的に起こりうるtipのポジションの制約を入れる
                self.modalViewBottomConstraint.constant = self.tipPositionConstant
            case .half: fatalError()
            }
            
            self.view.layoutIfNeeded()
        }
        
        animator.addCompletion { [weak self] position in
            guard let self = self else {return}
            // アニメーションが終わったときに呼ばれる
            switch self.currentMode {
            case .tip:
                if position == .start {
                    //tipの状態で開始し、tipのままにとどまった
                    self.modalViewBottomConstraint.constant = self.tipPositionConstant
                    self.currentMode = .tip
                } else if position == .end {
                    //tipの状態で開始し、fullになった
                    self.modalViewBottomConstraint.constant = self.fullpositionConstant
                    self.currentMode = .full
                }
            case .full:
                if position == .start {
                    //fullの状態で開始し、fullのままとどまった
                    self.modalViewBottomConstraint.constant = self.fullpositionConstant
                    self.currentMode = .tip
                } else if position == .end {
                    //fullの状態で開始し、tipになった
                    self.modalViewBottomConstraint.constant = self.tipPositionConstant
                    self.currentMode = .tip
                }
            case .half: fatalError()
            }
            
            self.view.layoutIfNeeded()
        }
        return animator
    }
    
    private func activeAnimator() {
        modalAnimator.startAnimation()
        modalAnimator.pauseAnimation()
    }
    
    private func stopModalAnimator() {
        modalAnimator.stopAnimation(false)
        modalAnimator.finishAnimation(at: .current)
    }
    
    // パンジェスチャーの終わりに呼ばれる
    private func continueInteractionAnimator(velocity: CGPoint) {
        let fractionComplete = modalAnimator.fractionComplete
        if currentMode.isBeginningArea(fractionPoint: fractionComplete, velocity: velocity, halfAreaBorderPoint: halfPositionFractionValue) {
            begginingAreaContinueInteractionAnimator(velocity: velocity)
        } else if currentMode.isEndArea(fractionPoint: fractionComplete, velocity: velocity, halfAreaBorderPoint: halfPositionFractionValue) {
            endAreaContinueInteractionAnimator(velocity: velocity)
        } else {
            halfAreaContinueInteractionAnimator(velocity: velocity)
        }
    }
    
    private func calculateContinueAnimatorParams(remainingDistance: CGFloat, velocity: CGPoint) -> (timingparameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        if remainingDistance == 0 {
            return (nil, 0)
        }
        let relativeVelocity = abs(velocity.y) / remainingDistance
        let timingParameters = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: relativeVelocity, dy: relativeVelocity))
        let newDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
        let durationFactor = CGFloat(newDuration/modalAnimator.duration)
        return(timingParameters, durationFactor)
    }
    
    private func begginingAreaContinueInteractionAnimator(velocity: CGPoint) {
        let remainingFraction = 1 - modalAnimator.fractionComplete
        let remainingDistance = maxDistance * remainingFraction
        modalAnimator.isReversed = true
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainingDistance, velocity: velocity)
        continueAnimator(parameters: continueAnimatorParams.timingparameters, durationFactor: continueAnimatorParams.durationFactor)
    }
    
    private func endAreaContinueInteractionAnimator(velocity: CGPoint){
        let remainingFraction = 1 - modalAnimator.fractionComplete
        let remainingDistance = maxDistance * remainingFraction
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainingDistance, velocity: velocity)
        let timingParameters = continueAnimatorParams.timingparameters
        let durationFactor = continueAnimatorParams.durationFactor
        modalAnimator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
        
    }
    
    
    private func halfAreaContinueInteractionAnimator(velocity: CGPoint) {
        modalAnimator.pauseAnimation()
        let toHalfDistance = currentMode == .tip ? tipToHalfDistance : halfToFullDistance
        remainigToHalfDistance = toHalfDistance - (maxDistance * modalAnimator.fractionComplete)
        
        modalAnimator.addAnimations {
            self.modalViewBottomConstraint.constant = self.halfPositionConstant
            self.view.layoutIfNeeded()
        }
        modalAnimator.addCompletion { [weak self] postion in
            guard let self = self else {return}
            self.isRunningToHalf = false
            switch postion {
            case .end:
                self.currentMode = .half
                self.modalViewBottomConstraint.constant = self.halfPositionConstant
            case .start, .current: ()
                @unknown default:
                ()
            }
            self.view.layoutIfNeeded()
        }
        isRunningToHalf = true
        activeAnimator()
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainigToHalfDistance, velocity: velocity)
        continueAnimator(parameters: continueAnimatorParams.timingparameters, durationFactor: continueAnimatorParams.durationFactor)
        
    }
    
    private func continueAnimator(parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        modalAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: durationFactor)
    }
}


extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchVC.hideHeader()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchVC.showHeader()
        searchVC.tableView.alpha = 1.0
    }
}

extension ViewController {
    private func lookScrollView(scrollView: UIScrollView) {
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func unlockScrollView(scrollView: UIScrollView) {
        scrollView.isDirectionalLockEnabled = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
    }
}
