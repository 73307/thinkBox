//
//  NotesViewController.swift
//  ThinkBox
//
//  Created by sudhanshu kumar on 08/09/25.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

class NotesViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textFiledNotes: UITextView!
    @IBOutlet weak var viewBottom: NSLayoutConstraint!
    @IBOutlet weak var textView: UIView!
    
    var noteItem: BoxItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFiledNotes.delegate = self
        
        if let noteItem = noteItem {
            textFiledNotes.text = noteItem.note
        }
        
        // ✅ Keyboard Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        // ✅ UI Styling
        textView.setBorder(color: .white, width: 2, cornerRadius: 12)
        textView.setShadow(opacity: 0.5, radius: 8)
        
        navigationItem.title = "Note"
        if #available(iOS 16.0, *) {
            navigationItem.rightBarButtonItem?.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
    }
    
    // MARK: - Keyboard Handling
    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom + 10
            viewBottom.constant = bottomInset
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let userInfo = notification.userInfo,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            viewBottom.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        guard let noteItem = noteItem else { return }
        
        // ✅ अब DataManager से save कर रहे हैं
        DataManager.shared.updateNote(for: noteItem, text: textView.text)
    }
}
