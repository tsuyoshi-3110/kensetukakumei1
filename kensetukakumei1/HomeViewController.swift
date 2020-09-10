//
//  HomeViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/02.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private lazy var deaiHomeViewController: DeaiHomeViewController = {
        let storyborad = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyborad.instantiateViewController(withIdentifier: "DeaiHome") as! DeaiHomeViewController
        add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var oenHomeViewController: OenHomeViewController = {
        let storyborad = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyborad.instantiateViewController(withIdentifier: "OenHome") as! OenHomeViewController
        add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var ukeoiHomeViewController: UkeoiHomeViewController = {
        let storyborad = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyborad.instantiateViewController(withIdentifier: "UkeoiHome") as! UkeoiHomeViewController
        add(asChildViewController: viewController)
        return viewController
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    private func setupView() {
        updateView()
    }
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: oenHomeViewController)
            remove(asChildViewController: ukeoiHomeViewController)
            add(asChildViewController: deaiHomeViewController)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            remove(asChildViewController: deaiHomeViewController)
            remove(asChildViewController: ukeoiHomeViewController)
            add(asChildViewController: oenHomeViewController)
        } else {
            remove(asChildViewController: deaiHomeViewController)
            remove(asChildViewController: oenHomeViewController)
            add(asChildViewController: ukeoiHomeViewController)
        }
    }
    @IBAction func tapSegmentedControl(_ sender: UISegmentedControl) {
        updateView()
    }
    private func add(asChildViewController viewController: UIViewController) {
        // 子ViewControllerを追加
        addChild(viewController)
        // Subviewとして子ViewControllerのViewを追加
        view.addSubview(viewController.view)
        // 子Viewの設定
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // 子View Controllerへの通知
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // 子View Controllerへの通知
        viewController.willMove(toParent: nil)
        // 子ViewをSuperviewから削除
        viewController.view.removeFromSuperview()
        // 子View Controllerへの通知
        viewController.removeFromParent()
    }
    
}
