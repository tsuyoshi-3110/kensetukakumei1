//
//  OenHomeViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/06.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase

class OenHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var yousei: UIButton!
    @IBOutlet weak var jyudaku: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    //投稿データを格納する配列
    var postArray: [PostOenData] = []
    
    //Firestoreのリスナー
    var listener: ListenerRegistration!
    
    @IBAction func youseiButton(_ sender: Any) {
        let YouseiViewController = storyboard!.instantiateViewController(withIdentifier: "Yousei")
        present(YouseiViewController, animated: true)
        
    }
    
    @IBAction func jyudakuButton(_ sender: Any) {
        let JyudakuViewController = storyboard!.instantiateViewController(withIdentifier: "Jyudaku")
        present(JyudakuViewController, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "PostOenTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        yousei.layer.cornerRadius = 5
        yousei.clipsToBounds = true
        
        jyudaku.layer.cornerRadius = 5
        jyudaku.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostOenPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostOenData(document: document)
                        return postData
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
            
        } else {
            //ログイン未
            if listener != nil {
                // listener登録済みなら
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostOenTableViewCell
        cell.setPostOenData(postArray[indexPath.row])
        
        //セル内のdmMailButtonが押されたときのアクションをソースコードで設定する
        cell.dmMailButton.addTarget(self,action:#selector(handledmMailButton(_:forEvent:)), for: .touchUpInside)
        return cell
    }
    // セル内のdmMailButtonがタップされた時に呼ばれるメソッド
    @objc func handledmMailButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //commentViewControllerにモーダル遷移
        let sendDMOenViewController = self.storyboard?.instantiateViewController(withIdentifier: "SendDMOen") as! SendDMOenViewController
        sendDMOenViewController.postOenData = postData
        self.present(sendDMOenViewController, animated: true, completion: nil)
        
    }
    
}








