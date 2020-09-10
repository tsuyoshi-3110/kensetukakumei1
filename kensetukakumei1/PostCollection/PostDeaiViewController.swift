//
//  PostDeaiViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/06.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostDeaiViewController: UIViewController {
    
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var profileData: ProfileData!
    
    
    @IBAction func postButton(_ sender: Any) {
        if let comment = self.commentTextView.text {
            
            // 表示名が入力されていない時はHUDを出して何もしない
            if comment.isEmpty {
                SVProgressHUD.showError(withStatus: "コメントを入力してください。")
                return
                
            }
        }
        if profileData == nil {
            //保存場所の定義
            let postRef = Firestore.firestore().collection(Const.PostDeaiPath).document()
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let userID = Auth.auth().currentUser?.uid
            
            let postDic = [
                "name": name!,
                "userID": userID!,
                "comment": commentTextView.text!,
                "date": FieldValue.serverTimestamp()
                ] as [String : Any]
            postRef.setData(postDic)
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            //投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            
        } else {
            let postRef = Firestore.firestore().collection(Const.PostDeaiPath).document()
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let userID = Auth.auth().currentUser?.uid
            
            let postDic = [
                "name": name!,
                "userID": userID!,
                "comment": commentTextView.text!,
                "imageNo": self.profileData.imageNo,
                "age": self.profileData.age!,
                "companyName": self.profileData.companyName!,
                "area": self.profileData.area!,
                "qualification": self.profileData.qualification!,
                "typeOfWork": self.profileData.typeOfWork!,
                "yearsEx": self.profileData.yearsEx!,
                "date": FieldValue.serverTimestamp()
                ] as [String : Any]
            postRef.setData(postDic)
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            //投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)                }
        
        
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = Auth.auth().currentUser else {
            // サインインしていない場合の処理をするなど
            return
        }
        //サインインしていれば、Firebaseからドキュメントをダウンロードする。
        Firestore.firestore().collection(Const.ProfilePath).document(user.uid).getDocument { (snap, error) in
            if let error = error {
                fatalError("\(error)")
            }
            //ダウンロードできているかの確認
            guard let data = snap?.data() else {
                return
            }
            print(data)
            
            //DocumentSnapshotクラスのデータをProfilerDataクラスに当てはめる
            self.profileData = ProfileData(document: snap!)
            print(self.profileData.age!)               // Do any additional setup after loading the view.
        }
        // 枠のカラー
        commentTextView.layer.borderColor = UIColor.darkGray.cgColor
        
        // 枠の幅
        commentTextView.layer.borderWidth = 1.0
        
        // 枠を角丸にする
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.layer.masksToBounds = true
        
         // 決定バーの生成
               let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
               let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
               let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
               toolbar.setItems([spacelItem, doneItem], animated: true)
        
        commentTextView.inputAccessoryView = toolbar
    }
     // 決定ボタン押下
       @objc func done() {
           self.view.endEditing(true)
       }
}
