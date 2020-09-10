//
//  PostUkeoiViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/06.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostUkeoiViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var typeOfWorkTextField: UITextField!
    @IBOutlet weak var conditionsTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    
    var profileData: ProfileData!
    
    var startDatePicker: UIDatePicker = UIDatePicker()
    var endDatePicker: UIDatePicker = UIDatePicker()
    
    var pickerView = UIPickerView()
    
    var pickerView1 = UIPickerView()
    
    let dataList = ["北海道・東北地方","北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県",
                    "関東地方","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県",
                    "中部地方","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県",
                    "近畿地方","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県",
                    "中国・四国地方","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県",
                    "九州・沖縄地方","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    let selectList = ["発注","受注"]
    
    @IBAction func postButton(_ sender: Any) {
        if let comment = self.commentTextView.text, let typeOFWork = typeOfWorkTextField.text, let Conditions = conditionsTextField.text, let area = areaTextField.text, let start = startTextField.text, let end = endTextField.text {
            
            // 全項目を入力しなければ、何もしないで返す。
            if comment.isEmpty || typeOFWork.isEmpty || Conditions.isEmpty || area.isEmpty || start.isEmpty || end.isEmpty {
                SVProgressHUD.showError(withStatus: "全項目を入力してください。")
                return
            }
            
            //保存先を指定
            let postRef = Firestore.firestore().collection(Const.PostUkeoiPath).document()
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let userId = Auth.auth().currentUser?.uid
            let postDic = [
                "name": name!,
                "userID": userId!,
                "conditions": self.conditionsTextField.text!,
                "comment": self.commentTextView.text!,
                "imageNo": self.profileData.imageNo,
                "age": self.profileData.age!,
                "companyName": self.profileData.companyName!,
                "area": self.areaTextField.text!,
                "start": self.startTextField.text!,
                "end": self.endTextField.text!,
                "qualification": self.profileData.qualification!,
                "typeOfWork": self.typeOfWorkTextField.text!,
                "yearsEx": self.profileData.yearsEx!,
                "date": FieldValue.serverTimestamp()
                ] as [String : Any]
            postRef.setData(postDic)
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            //投稿処理が完了したので先頭画面に戻る
            let tabBarController = UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 0
            tabBarController.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //StartDatePickerの設定
        startDatePicker.datePickerMode = UIDatePicker.Mode.date
        startDatePicker.timeZone = NSTimeZone.local
        startDatePicker.locale = Locale.current
        startTextField.inputView = startDatePicker
        
        
        
        //endDatePickerの設定
        endDatePicker.datePickerMode = UIDatePicker.Mode.date
        endDatePicker.timeZone = NSTimeZone.local
        endDatePicker.locale = Locale.current
        endTextField.inputView = endDatePicker
        
        
        
        // startDatePikerの決定バーの生成
        let Tbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let SItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let endItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(end))
        Tbar.setItems([SItem, endItem], animated: true)
        
        //tagを使わずに分ける時用
        //endDatePikerの決定バーの生成
        let T1bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let S1Item = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let end1Item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(end1))
        T1bar.setItems([S1Item, end1Item], animated: true)
        
        
        // 各DatePickerのインプットビュー設定
        startTextField.inputAccessoryView = Tbar
        endTextField.inputAccessoryView = T1bar
        //エリアのピッカービュー
        // PickerView のサイズと位置
        pickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
        // PickerViewはスクリーンの中央に設定
        pickerView.center = self.view.center
      
        
        //Selectのピッカービュー
        // PickerView のサイズと位置
        pickerView1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
        // PickerViewはスクリーンの中央に設定
        pickerView1.center = self.view.center
        
        
        //地域、工種のツールバーの設定
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //セレクトのピッカービューデリゲート
        pickerView1.delegate = self
        pickerView1.dataSource = self
        
        areaTextField.inputView = pickerView
        areaTextField.inputAccessoryView = toolbar
        typeOfWorkTextField.inputAccessoryView = toolbar
        commentTextView.inputAccessoryView = toolbar
        
        
        //条件設定のツールバーの設定
        // 決定バーの生成
        let Toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let SpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let DoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(Done))
        Toolbar.setItems([SpacelItem, DoneItem], animated: true)
        
        //条件設定のツールバー
        conditionsTextField.inputAccessoryView = Toolbar
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
            //ダウンロードできているかの確認
            guard let data = snap?.data() else {
                SVProgressHUD.showError(withStatus: "プロフィールを設定してください。")
                let tabBarController = UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController as! UITabBarController
                tabBarController.selectedIndex = 2
                tabBarController.dismiss(animated: true, completion: nil)
                return
            }
            print(data)
            
            //DocumentSnapshotクラスのデータをProfilerDataクラスに当てはめる
            self.profileData = ProfileData(document: snap!)
            print(self.profileData.age!)
            
            if self.profileData == nil || self.profileData.age == "" || self.profileData.companyName == "" || self.profileData.area == "" || self.profileData.yearsEx == "" || self.profileData.typeOfWork == "" {
                SVProgressHUD.showError(withStatus: "プロフィールを設定してください。")
                let tabBarController = UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController as! UITabBarController
                tabBarController.selectedIndex = 2
                tabBarController.dismiss(animated: true, completion: nil)
                return
            }
        }
        // 枠のカラー
        commentTextView.layer.borderColor = UIColor.darkGray.cgColor
        
        // 枠の幅
        commentTextView.layer.borderWidth = 1.0
        
        // 枠を角丸にする
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.layer.masksToBounds = true
    }
    
    // 決定ボタン押下
    @objc func end(_ datePicker: UIDatePicker) {
        
        startTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        startTextField.text = "\(formatter.string(from: startDatePicker.date))"
        
    }
    
    @objc func end1() {
        endTextField.endEditing(true)
        //日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        endTextField.text = "\(formatter.string(from: endDatePicker.date))"
    }
    
    
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return dataList.count
        }
        return selectList.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return dataList[row]
        } else {
            return selectList[row]
        }
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
            areaTextField.text = dataList[row]
    }
    // 決定ボタン押下
    @objc func done() {
        self.view.endEditing(true)
    }
    
    // 決定ボタン押下
    @objc func Done() {
        self.conditionsTextField.endEditing(true)
        
        // 金額表記で三行毎にカンマ区切りにする。　数値にする場合は、.currencyを.decimalに変換する
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.groupingSeparator = "," // 区切り文字を指定
        f.groupingSize = 3 // 何桁ごとに区切り文字を入れるか指定
        
        //conditionTextField.textの値をIntに変換。その場合にStringをIntに変換する際はnilになる可能性があるのでif let　等でアンラップ。
        if let conditionInt = Int(conditionsTextField.text ?? "") {
            //NSNumber型conditionInt.Int型をString型に変換してTextFieldに代入。
            self.conditionsTextField.text = f.string(from: NSNumber(integerLiteral: conditionInt))
            print(conditionsTextField.text!)
        }
    }
    
}
