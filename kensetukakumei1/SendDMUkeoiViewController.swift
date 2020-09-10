//
//  SendDMUkeoiViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/24.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SendDMUkeoiViewController: UIViewController {
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var postUkeoiData: PostUkeoiData?
    
    var profileData: ProfileData?
    
    @IBAction func SendButton(_ sender: Any) {
        if let mail = commentTextView.text {
            if mail.isEmpty {
                SVProgressHUD.showError(withStatus: "入力してください。")
                return
            }
            
            Firestore.firestore().collection(Const.ProfilePath).document(self.postUkeoiData!.userID!).getDocument { (snap, error) in
                if let error = error {
                    fatalError("\(error)")
                }
                //ダウンロードできているかの確認
                guard let data = snap?.data() else {
                   
                    return
                }
                print(data)
                
                //DocumentSnapshotクラスのデータをProfilerDataクラスに当てはめる
                let postProfileData = ProfileData(document: snap!)
        
            let name = Auth.auth().currentUser?.displayName
            let senderId = Auth.auth().currentUser?.uid
            
            //chatMessageの保存先を指定
            let chatRoomRef = Firestore.firestore().collection(Const.PostChatRoom).document()
            let chatRoomDic = [
                "senderName": name!,
                "senderId": senderId!,
                "senderImageNo": self.profileData!.imageNo,
                "chatRoomId": self.getChatRoomId(uid1: postProfileData.id, uid2: senderId!),
                "chatMessage": self.commentTextView.text!,
                "date": FieldValue.serverTimestamp()
                ] as [String: Any]
            chatRoomRef.setData(chatRoomDic)
                
                 
                
                if postProfileData.chatRoom != nil {
                postProfileData.chatRoom?.updateValue(chatRoomRef.documentID, forKey: senderId!)
    
            //FirebaseのusersにchatRoomを追加
                let postRef = Firestore.firestore().collection(Const.ProfilePath).document(postProfileData.id)
                    postRef.updateData(["chatRoom":postProfileData.chatRoom!])
                    print(postProfileData.chatRoom ?? "")
                } else {
                    
                    //FirebaseのusersにchatRoomを追加
                    let postRef = Firestore.firestore().collection(Const.ProfilePath).document(postProfileData.id)
                    postRef.updateData(["chatRoom":[senderId:chatRoomRef.documentID]])
                    print(postProfileData.chatRoom ?? "プロフィールデータのチャットルームはnil")
                    
                    
                }
                
               
             
                
                self.commentTextView.text = ""
                self.commentTextView.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 枠のカラー
        commentTextView.layer.borderColor = UIColor.darkGray.cgColor
        // 枠の幅
        commentTextView.layer.borderWidth = 1.0
        // 枠を角丸にする
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.layer.masksToBounds = true
        
        
        //ユーザーの認証
        guard let user = Auth.auth().currentUser else {
            // サインインしていない場合の処理をするなど
            return
        }
        
        //サインインしていれば、Firebaseからドキュメントをダウンロードする。
        Firestore.firestore().collection(Const.ProfilePath).document(user.uid).getDocument { (snap, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = snap?.data() else {
                SVProgressHUD.showError(withStatus: "プロフィールを設定してください。")
                
                return
            }
            print(data)
            self.profileData = ProfileData(document: snap!)
            
           
        }
    }
    
    func getChatRoomId(uid1: String, uid2: String) -> String {
        if uid1 < uid2 {
            return "\(uid1)_\(uid2)"
        } else {
            return "\(uid2)_\(uid1)"
        }
    }
    
}


