//
//  SendDMDeaiViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/30.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SendDMDeaiViewController: UIViewController {
    
    @IBOutlet weak var commentTextView: InspectableTextView!
    
    var postDeaiData: PostDeaiData?
    
    var profileData: ProfileData?
    
    @IBAction func sendButton(_ sender: Any) {
        if let mail = commentTextView.text {
            if mail.isEmpty {
                SVProgressHUD.showError(withStatus: "入力してください。")
                return
            }
            
            //投稿者のプロフィールデータを取得
            Firestore.firestore().collection(Const.ProfilePath).document(self.postDeaiData!.userID!).getDocument { (snap, error) in
                if let error = error {
                    fatalError("\(error)")
                }
                //ダウンロードできているか確認
                guard let data = snap?.data() else {return}
                print(data)
                
                //投稿者のプロフデータ(DocumentSnapshot型→profileData型)を変換
                let postProfileData = ProfileData(document: snap!)
                
                let name = Auth.auth().currentUser?.displayName
                let senderId = Auth.auth().currentUser?.uid
                
                //メッセージの保存先を指定
                let chatRoomRef = Firestore.firestore().collection(Const.PostChatRoom).document()
                //保存内容をセット
                let chatRoomDic = [
                    "senderName": name!,
                    "senderId": senderId!,
                    "senderImageNo": self.profileData!.imageNo,
                    "chatRoomId": self.getChatRoomId(uid1: postProfileData.id, uid2: senderId!),                    "chatMessage": self.commentTextView.text!,
                    "date": FieldValue.serverTimestamp()
                    ] as [String: Any]
                chatRoomRef.setData(chatRoomDic)
                
                if postProfileData.chatRoom != nil {
                    //投稿者のprofileData.chatRoomに既存するなら追加してアップデート
                    postProfileData.chatRoom?.updateValue(chatRoomRef.documentID, forKey: senderId!)
                    //FirebaseのusersにchatRoomをアップデート
                    let postRef = Firestore.firestore().collection(Const.ProfilePath).document(postProfileData.id)
                    postRef.updateData(["chatRoom":postProfileData.chatRoom!])
                } else {
                    //FirebaseのusersにchatRoomを新設
                    let postRef = Firestore.firestore().collection(Const.ProfilePath).document(postProfileData.id)
                    postRef.updateData(["chatRoom":[senderId:chatRoomRef.documentID]])
                    
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
        
        //枠のカラー
        commentTextView.layer.borderColor = UIColor.darkGray.cgColor
        //枠の幅
        commentTextView.layer.borderWidth = 1.0
        //枠を角丸にする
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        
        //ユーザーの認証
        guard let user = Auth.auth().currentUser else {return}
        
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
        // Do any additional setup after loading the view.
    }
    
    func getChatRoomId(uid1: String, uid2: String) -> String {
        if uid1 < uid2 {
            return "\(uid1)_\(uid2)"
        } else {
            return "\(uid2)_\(uid1)"
        }
    }
    
}
