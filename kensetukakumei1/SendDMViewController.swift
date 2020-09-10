//
//  SendDMViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/02.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SendDMViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mailTextView: UITextView!
    
    
    var postArray: [ChatRoomData] = []
    
    var listener: ListenerRegistration!
    
    var senderUid: String = ""
    
    var profileData: ProfileData?
    
    var senderProfileData: ProfileData?
    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMailButton(_ sender: Any) {
        
       
        
        if let mail = mailTextView.text {
            if mail.isEmpty {
                SVProgressHUD.showError(withStatus: "入力してください。")
                return
            }
            let id = Auth.auth().currentUser?.uid
            //返信の保存先を指定
            let chatRoomRef = Firestore.firestore().collection(Const.PostChatRoom).document()
            //保存内容をセット
            let chatRoomDic = [
                "senderName": profileData!.name!,
                "senderId": profileData!.id,
                "senderImageNo": profileData!.imageNo,
                "chatRoomId": getChatRoomId(uid1: id!, uid2: senderUid),
                "chatMessage": mailTextView.text!,
                "date": FieldValue.serverTimestamp()
                ] as [String: Any]
            chatRoomRef.setData(chatRoomDic)
            
            if senderProfileData?.chatRoom != nil {
                //送信者のsenderProfileData.chatRoomが既存するならそこに追加してアップデートする。
                senderProfileData?.chatRoom?.updateValue(chatRoomRef.documentID, forKey: self.profileData!.id)
                //Firebaseのusersにある送信者のプロフィールデータにchatRoomを追加
                let postRef = Firestore.firestore().collection(Const.ProfilePath).document(senderUid)
                postRef.updateData(["chatRoom":senderProfileData!.chatRoom!])
            } else {
                //送信者のchatRoomが存在しない場合Firebaseのusersの送信者のプロフィールデータにchatRoomを新設
                let postRef = Firestore.firestore().collection(Const.ProfilePath).document(senderUid)
                postRef.updateData(["chatRoom":[profileData!.id:chatRoomRef.documentID]])
            }
           
            self.mailTextView.text = ""
            self.mailTextView.endEditing(true)
            
            
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "ChatRoomTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
        //キーボードの出現に合わせてviewをスライドする設定
        self.mailTextView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        mailTextView.inputAccessoryView = toolbar
        
        // 枠のカラー
        mailTextView.layer.borderColor = UIColor.darkGray.cgColor
        // 枠の幅
        mailTextView.layer.borderWidth = 1.0
        // 枠を角丸にする
        mailTextView.layer.cornerRadius = 5.0
        mailTextView.layer.masksToBounds = true
        
        //ユーザーの認証,ユーザーのプロフィールデータを取得
        guard let user = Auth.auth().currentUser else {return}
        
        Firestore.firestore().collection(Const.ProfilePath).document(user.uid).getDocument { (snap, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = snap?.data() else {
                SVProgressHUD.showError(withStatus: "プロフィールを設定してください。")
                return
            }
            print("現在のユーザーのプロフィールデータ\(data)")
            self.profileData = ProfileData(document: snap!)
            
            //送信者のプロフィールデータを取得
            Firestore.firestore().collection(Const.ProfilePath).document(self.senderUid).getDocument{ (snap, error) in
                if let error = error {
                    print("\(error)")
                }
                guard let data = snap?.data() else {
                    SVProgressHUD.showError(withStatus: "プロフィールを設定してください。")
                    return
                }
                print("送信者のプロフィールデータ\(data)")
                self.senderProfileData = ProfileData(document: snap!)
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: SendDM viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            
            let id = Auth.auth().currentUser?.uid
            
            //ログイン済み
            if listener == nil {
                //listener未登録なら、登録してスナップショットを受信する
                let postRef = Firestore.firestore().collection(Const.PostChatRoom).whereField("chatRoomId", isEqualTo: getChatRoomId(uid1: id!, uid2: senderUid)).order(by:"date", descending: false)
                listener = postRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました\(error)")
                        return
                    }
                    //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得\(document.documentID)")
                        let postData = ChatRoomData(document: document)
                        return postData
                    }
                    self.tableView.reloadData()
                }
                
            }
        } else {
            //ログイン未
            if listener != nil{
                //listenerl登録済みなら
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
        
    }
    //テーブルビューを一番下のセルまでスクロール
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(row: self.postArray.count - 1 , section: 0)
        self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: false)
        
    }
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatRoomTableViewCell
        cell.setChatRoomData(postArray[indexPath.row])
        
        return cell
    }
    
    
    
    @objc func done() {
        self.view.endEditing(true)
        let indexPath = IndexPath(row: self.postArray.count - 1 , section: 0)
        self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: false)
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            // キーボードの高さを下のスペースにセット
            self.bottomSpace.constant = keyboardHeight
            
            // 一番下のセルがTableViewで表示されるようにする
            DispatchQueue.main.async {
                // 最後のセルのIndexPathを指定
                let indexPath = IndexPath(row: self.postArray.count - 1 , section: 0)
                // sectionは常に0、最後のセルの行番号はデータの数マイナス１
                
                self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: false)
                // 引数の説明
                // at: 上で取得した最後のセルのindexPath
                // at: TableViewのどこを基準にスクロールするか
                // animated: スクロールする時に動きを見せるかどうか
                
            }
        }
    }
    
    @objc func keyboardWillHide() {
        self.bottomSpace.constant = 10
    }
}

func getChatRoomId(uid1: String, uid2: String) -> String {
    if uid1 < uid2 {
        return "\(uid1)_\(uid2)"
    } else {
        return "\(uid2)_\(uid1)"
    }
}


extension SendDMViewController: UITextViewDelegate {
    
    func ShouldReturn(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

