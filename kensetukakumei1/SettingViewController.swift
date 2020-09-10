//
//  SettingViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/07.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import EventKit
import SVProgressHUD
import CLImageEditor
import FirebaseUI

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var qualificationTextField: UITextField!
    @IBOutlet weak var typeOfWorkTextField: UITextField!
    @IBOutlet weak var yearsOfExTextField: UITextField!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    //　firebaseのイメージを更新するために設け、ユーザーが写真を設定し直すたびに+1される
    var imageNo: Int = 0
    
    var profileImage: UIImage!
    
    var datePicker = UIDatePicker()
    var pickerView = UIPickerView()
    var pickerView1 = UIPickerView()
    
    let dataList = ["北海道・東北地方","北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県",
                    "関東地方","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県",
                    "中部地方","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県",
                    "近畿地方","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県",
                    "中国・四国地方","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県",
                    "九州・沖縄地方","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    let yearsdataList = ["1年以上","2年以上","3年以上","4年以上","5年以上","6年以上","7年以上","8年以上","9年以上","10年以上","11年以上","12年以上","13年以上","14年以上","15年以上","16年以上","17年以上","18年以上","19年以上","20年以上","21年以上","22年以上","23年以上","24年以上","25年以上","26年以上","27年以上","28年以上","29年以上","30年以上","31年以上","32年以上","33年以上","34年以上","35年以上","36年以上","37年以上","38年以上","39年以上","40年以上","41年以上","42年以上","43年以上","44年以上","45年以上","46年以上","47年以上","48年以上","49年以上","50年以上"]
    
    
    var name: String!
    var age: String!
    var companyName: String!
    var area: String!
    var qualification: String!
    var typeOfWork: String!
    var yearsEx: String!
    
    
    var profileData: ProfileData!
    
    //imegeを更新させるために設けた数字
    var imageNumber = 0
    
    //設定ボタン
    @IBAction func setButton(_ sender: Any) {
        
        //プロフィールイメージが空ではない時にはしらす処理
        if profileImage != nil {
            guard let user = Auth.auth().currentUser else {
                // サインインしていない場合の処理をするなど
            return
            }
            
           //初期設定段階ではprofileDataはnilなので、SettingVCに設置されたプロパティーのimageNo=0が適用される。　それ以後はぷprofileData.imageNoが適用される。
            if profileData != nil {
                imageNumber = profileData.imageNo
            }
            //画像をJPEG形式に変換する
            let imageData = profileImage.jpegData(compressionQuality: 0.01)
            
            //画像と投稿データの保存場所を定義する
            let postRef = Firestore.firestore().collection(Const.ProfilePath).document(user.uid)
            let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child( user.uid + "_" + String(imageNumber + 1) + ".jpg")
            SVProgressHUD.show()
            
            //Storageに画像をアップロードする
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imageRef.putData(imageData!, metadata: metadata){(metadata, error) in
                if error != nil {
                    //画像のアップロード失敗
                    print(error!)
                    SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しまいした")
                    //投稿処理をキャンセルし、先頭画面に戻る
                    return
                }
                if let displayName = self.nameTextField.text {
                    
                    // 表示名が入力されていない時はHUDを出して何もしない
                    if displayName.isEmpty {
                        SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                        return
                        
                    }
                    // 表示名を設定する
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        // HUDで完了を知らせる
                        SVProgressHUD.showSuccess(withStatus: "プロフィールを変更しました。")
                        //投稿処理が完了したのでせ先頭画面に戻る
                        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                        
                    }
                }                //FireStoreに投稿データを保存する
                let name = Auth.auth().currentUser?.displayName
                let postDic = [
                    "name": name!,
                    "imageNo": self.imageNumber + 1,
                    "age": self.ageTextField.text!,
                    "companyName": self.companyNameTextField.text!,
                    "area": self.areaTextField.text!,
                    "qualification": self.qualificationTextField.text!,
                    "typeOfWork": self.typeOfWorkTextField.text!,
                    "yearsEx": self.yearsOfExTextField.text!,
                    "date": FieldValue.serverTimestamp()
                    ] as [String : Any]
                postRef.setData(postDic)
                //HUDで投稿完了を表示する
                SVProgressHUD.showSuccess(withStatus: "投稿しました")
                
                
            }
            
            
            
            
        } else {
            
            
            //プロフィールイメージが空の時に実行される
            
            guard let user = Auth.auth().currentUser else {
                // サインインしていない場合の処理をするなど
                return
            }
            if profileData != nil {
                imageNumber = profileData.imageNo
            }
            if let displayName = nameTextField.text {
                
                // 表示名が入力されていない時はHUDを出して何もしない
                if displayName.isEmpty {
                    SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                    return
                    
                }
                // 表示名を設定する
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "プロフィールを変更しました。")
                    //投稿処理が完了したので先頭画面に戻る
                    UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                }
            }
            //保存場所の定義
            let postRef = Firestore.firestore().collection(Const.ProfilePath).document(user.uid)
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "imageNo": self.imageNumber,
                "age": self.ageTextField.text!,
                "companyName": self.companyNameTextField.text!,
                "area": self.areaTextField.text!,
                "qualification": self.qualificationTextField.text!,
                "typeOfWork": self.typeOfWorkTextField.text!,
                "yearsEx": self.yearsOfExTextField.text!,
                "date": FieldValue.serverTimestamp()
                ] as [String : Any]
            postRef.setData(postDic)
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
        }
    }
    
    
    
    
    
    
    //キャンセルボタン
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //もしプロフィールデータがnilではない時の処理　profileDataはSetProfileVCで Firebaseからダウンロードした値を、profileDataたクラスに反映し、それを遷移の際に、渡された
        if let profile = profileData {
            
            //displayNameをFirebaseから取得
            let name = Auth.auth().currentUser?.displayName
            
            //各TestField.textにProfileDataクラスが保持している値を当てはめていく
            nameTextField.text = name
            ageTextField.text = profile.age
            companyNameTextField.text = profile.companyName
            areaTextField.text = profile.area
            qualificationTextField.text = profile.qualification
            typeOfWorkTextField.text = profile.typeOfWork
            yearsOfExTextField.text = profile.yearsEx
            
            
            // Firebaseからダウンロードした画像の表示
            self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(profile.id + "_" + String(profile.imageNo) + ".jpg")
            self.imageView.sd_setImage(with: imageRef)
            
        }
        
        //デートピッカーの表示方法をデフォルトから年月日に変更
        datePicker.datePickerMode = UIDatePicker.Mode.date
        // デートピッカーの完了バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // デートピッカーのインプットビュー設定
        ageTextField.inputView = datePicker
        ageTextField.inputAccessoryView = toolbar
        
        
        
        // TextFieldのツールバー生成
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        toolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        toolBar.sizeToFit()
        // 閉じるボタンを右に配置するためのスペース?
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commitButtonTapped))
        // スペース、閉じるボタンを右側に配置
        toolBar.items = [spacer, commitButton]
        
        
        // TextFieldのキーボードにツールバーを設定
        nameTextField.inputAccessoryView = toolBar
        companyNameTextField.inputAccessoryView = toolBar
        qualificationTextField.inputAccessoryView = toolBar
        typeOfWorkTextField.inputAccessoryView = toolBar
        
        //areaTextFieldでピッカービューを設定
        // PickerView のサイズと位置
        pickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
        // PickerViewはスクリーンの中央に設定
        pickerView.center = self.view.center
        pickerView.tag = 0
        
        // 経験年数　PickerView のサイズと位置
        pickerView1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
        // PickerViewはスクリーンの中央に設定
        pickerView1.center = self.view.center
        pickerView1.tag = 1
        // ピッカービュー完了ボタン生成
        let Toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let SpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let DoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(Done))
        Toolbar.setItems([SpacelItem, DoneItem], animated: true)
        
        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self
        //経験年数のpickerViewデリゲート
        pickerView1.delegate = self
        pickerView1.dataSource = self
        
        //pickerViewのインプットビューの設定
        areaTextField.inputView = pickerView
        areaTextField.inputAccessoryView = Toolbar
        
        //経験年数のpickerViewのインプットビューの設定
        yearsOfExTextField.inputView = pickerView1
        yearsOfExTextField.inputAccessoryView = Toolbar
        
        //画像の角を丸くする。
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
              // Initialization code
    }
    //TextField関係のツールバーの完了ボタンをタップ
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
    }
    
    // datepickerの完了ボタンタップ
    @objc func done() {
        ageTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        ageTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return dataList.count
        }else{
            return yearsdataList.count
        }
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return dataList[row]
            
        }else{
            return yearsdataList[row]
        }
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if pickerView.tag == 0 {
            areaTextField.text = dataList[row]
        }else{
            yearsOfExTextField.text = yearsdataList[row]
        }
    }
    // 地域、経験年数のpickerViewの完了ボタンをタップ
    @objc func Done() {
        self.view.endEditing(true)
    }
    
    
    //画像設定ボタン
    @IBAction func imageSetButton(_ sender: Any) {
        //ライブラリ（カメラロール）。を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
    }
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            
            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            
            picker.present(editor, animated: true, completion: nil)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く
        
        profileImage = image!
        imageView.image = profileImage
        
        self.dismiss(animated: true, completion: nil)
        
    }
    // CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
          
        self.dismiss(animated: true, completion: nil)
    }
}


