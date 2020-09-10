//
//  PostMatterViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/02.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit

class PostMatterViewController: UIViewController {
    @IBOutlet weak var postDeai: UIButton!
    @IBOutlet weak var postOen: UIButton!
    @IBOutlet weak var postUkeoi: UIButton!
    
    @IBAction func postDeaiButton(_ sender: Any) {
         let PostDeaiViewController = storyboard!.instantiateViewController(withIdentifier: "PostDeai")
                   present(PostDeaiViewController, animated: true)
        
    }
    
    @IBAction func postOenButton(_ sender: Any) {
         let PostOenViewController = storyboard!.instantiateViewController(withIdentifier: "PostOen")
                          present(PostOenViewController, animated: true)
        
    }
    
    @IBAction func postUkeoiButton(_ sender: Any) {
        let PostUkeoiViewController = storyboard!.instantiateViewController(withIdentifier: "PostUkeoi")
        present(PostUkeoiViewController, animated: true)
        
    }
    
    @IBAction func backButton(_ sender: Any) {
           self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        postDeai.layer.cornerRadius = 5
        postDeai.clipsToBounds = true
        
        postOen.layer.cornerRadius = 5
        postOen.clipsToBounds = true
        
        postUkeoi.layer.cornerRadius = 5
        postUkeoi.clipsToBounds = true
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
