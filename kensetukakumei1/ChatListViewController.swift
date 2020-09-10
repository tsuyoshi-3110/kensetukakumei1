//
//  ChatListViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/24.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var uidArray: [String] = []
    
    var chatRoomDic: [String:String] = [:]
    
    var lastMessageArray: [String] = []
    
    var uidListener: ListenerRegistration!
    
    var profileData: ProfileData!
    
    var usersArray: [UsersData] = []
    
    var usersListener: ListenerRegistration!
    
    var uid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        // Do any additional setup after loa
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            //ログイン済み
            if uidListener == nil {
                let id = Auth.auth().currentUser?.uid
                
                let uidRef = Firestore.firestore().collection(Const.ProfilePath).document(id!)
                uidListener = uidRef.addSnapshotListener() { (snap, error) in
                    if let error = error {
                        fatalError("\(error)")
                    }
                    //ダウンロードできているかの確認
                    guard let data = snap?.data() else {
                        return
                    }
                    print(data)
                    
                    self.profileData = ProfileData(document: snap!)
                    
                    if self.profileData.chatRoom != nil {
                        print(self.profileData.chatRoom ?? "チャットルームが空です。")
                        self.uidArray = Array(self.profileData.chatRoom!.keys)
                        self.chatRoomDic = self.profileData.chatRoom!
                       
                        
                    } else {
                        
                        return
                    }
                    self.tableView.reloadData()
                }
            }
            
            
            if usersListener == nil {
                
                let usersRef = Firestore.firestore().collection(Const.ProfilePath)
                usersListener = usersRef.addSnapshotListener() { (querySnapshot,error)in
                    if let error = error{
                        print("DEBUG/PRINT: usersSnapshotの取得が失敗しました。\(error)")
                        return
                    }
                    
                    self.usersArray = querySnapshot!.documents.map { document in
                        
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let usersData = UsersData(document: document)
                        return usersData
                    }
                    
                    self.tableView.reloadData()
                }
            }
        } else {
            if uidListener != nil {
                uidListener.remove()
                uidListener = nil
                uidArray = []
                tableView.reloadData()
            } else if usersListener != nil {
                usersListener.remove()
                usersListener = nil
                usersArray = []
                tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uidArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatListTableViewCell
        let uid = uidArray[indexPath.row]
        let profileDataArray = usersArray.filter{ $0.id == uid}
        if let pFirst = profileDataArray.first {
            cell.setChatListData(pFirst)
        }
        //uidArray[indexPath.row]を使用しchatRoomDicの要素を取得、それを元に情報をchatRoomから取得する
        if let lastMessageId = chatRoomDic[uid]{
            Firestore.firestore().collection(Const.PostChatRoom).document(lastMessageId).getDocument { (snap, error) in
                if let error = error {
                    fatalError("\(error)")
                }
                //ダウンロードできているかの確認
                guard let data = snap?.data() else {return}
                print(data)
                
                //取得したデータかららラストメッセージを取得
                let postDic = data
                let lastMessage = postDic["chatMessage"] as? String
                cell.lastMessageLabel.text = lastMessage
                
                
                //日時の表示
                let timestamp = postDic["date"] as? Timestamp
                let date = timestamp?.dateValue()
                
                cell.dateLabel.text = ""
                if let lastDate = date{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM-dd HH:mm"
                    let dateString = formatter.string(from: lastDate)
                    cell.dateLabel.text = dateString
                }
                
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let sendDMViewController:SendDMViewController = segue.destination as! SendDMViewController
        let indexPath = self.tableView.indexPathForSelectedRow
        sendDMViewController.senderUid = uidArray[indexPath!.row]
    }
}
