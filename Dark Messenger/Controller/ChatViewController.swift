//
//  ChatViewController.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 01/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var messageArray : [Message] = [Message]()
    var selectedFriend : User? {
        didSet {
            retrieveChat()
        }
    }
    let currentUser = Auth.auth().currentUser?.email
    var duration : NSNumber = 0
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var bottomChatContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Message", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078, alpha: 1)])
        messageTextField.layer.cornerRadius = 15
        messageTextField.clipsToBounds = true
        
        messageTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.MessageTime.text = messageArray[indexPath.row].timestamp
        cell.contentView.superview?.clipsToBounds = true
        cell.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email! {
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.02317308635, green: 0.4005458057, blue: 0.8445877433, alpha: 1)
            cell.rightBackgroundConstraint.constant = 10
            cell.leftBackgroundConstraint.constant = 60
        } else {
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.3315302134, green: 0.3315826654, blue: 0.3315187693, alpha: 1)
            cell.leftBackgroundConstraint.constant = 10
            cell.rightBackgroundConstraint.constant = 60
        }
        
        self.view.setNeedsLayout()
        return cell
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight : Int = Int(keyboardSize.height)
            let bottomInset = Int(view.safeAreaInsets.bottom)
            keyboardHeight -= bottomInset
            
            UIView.animate(withDuration: TimeInterval(truncating: duration)) {
                self.heightConstraint.constant = CGFloat(keyboardHeight + 50)
                self.view.layoutIfNeeded()
                self.messageTableView.scrollToBottom()
            }
        }
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: TimeInterval(truncating: duration)) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    func retrieveChat() {
        self.title = selectedFriend!.name
        let messagesDB = Database.database().reference().child("Messages").child(selectedFriend!.chatId)
        
        messagesDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
            let message = Message()
            
            message.messageBody = snapshotValue["messageBody"]! as! String
            message.sender = snapshotValue["sender"]! as! String
            message.timestamp = self.convertTimestamp(serverTimestamp: snapshotValue["timestamp"] as! Double)

            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
            self.messageTableView.scrollToBottom()
        }
        
    }
    
    func convertTimestamp(serverTimestamp: Double) -> String {
        let x = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: date as Date)
    }

    @IBAction func sendPressed(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.isEnabled = false
            sendButton.isEnabled = false
            messageTextField.endEditing(false)
            
            let messageDictionary = [
                "sender": currentUser as Any,
                "messageBody": messageTextField.text!,
                "timestamp": ServerValue.timestamp()
            ] as [String : Any]
            
            let messagesDB = Database.database().reference().child("Messages").child(selectedFriend!.chatId)
            messagesDB.childByAutoId().setValue(messageDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextField.text = ""
                }
            }
        }
    }
}

extension UITableView {
    func scrollToBottom(){
        DispatchQueue.main.async {
            let numberOfRows = self.numberOfRows(inSection:  self.numberOfSections - 1) - 1
            if (numberOfRows > 0) {
                let indexPath = IndexPath(row: numberOfRows, section: self.numberOfSections - 1)
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
