//
//  ReceiptDetailViewController.swift
//  ReceiptKeeper
//
//  Created by Perez Willie Nwobu on 11/5/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import UIKit
import NotificationCenter

class ReceiptDetailViewController: UIViewController , UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    override func viewDidLoad() {
        super.viewDidLoad()
      receiptNotes.keyboardAppearance = .dark
       receiptTitle.keyboardAppearance = .dark
        
        //imgView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        imageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        imageView.isUserInteractionEnabled = true
        if receipt == nil {
            receiptNotes.textColor = UIColor.lightGray
            receiptNotes.text = text
        }

       updateViews()
        receiptNotes.delegate = self
        receiptTitle.delegate = self
   
        
        //ListenForKeyBoardEvents
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShownotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShownotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShownotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        //StopListening
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //TriggerWhenTheListenersCallUs
    @objc func keyboardWillShownotification(notification : Notification){
        //Get size of the keyboard and increase the view by the size of the keyboard
        guard let keyBoardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        
        if notification.name == UIResponder.keyboardWillChangeFrameNotification || notification.name == UIResponder.keyboardWillShowNotification {
        view.frame.origin.y = -keyBoardHeight.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if receiptNotes.text ==  text {
            receiptNotes.text = ""
            receiptNotes.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = receiptTitle.text, !name.isEmpty else {
            return
        }
        
        let  notes = receiptNotes.text
        let priorityIndex = segmentControl.selectedSegmentIndex
        let priority = ReceiptPriority.allCases[priorityIndex]
        guard let image = imageView.image else {return}
        let imageData: Data = image.pngData()!
        
        if let receipt  = receipt {
            //editing
            receipt.name = name
            receipt.priority = priority.rawValue
            receipt.notes = notes
            receipt.imageData = imageData
        } else {
            //new stuff
            
            let _ =  Receipt(name: name, notes: notes,  imageData: imageData, priority : priority)
        }
        
        do {
            let moc = CoreDataStack.shared.mainContext
           try  moc.save()
        }catch {
            NSLog("Error saving managed object context : \(error)")
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
         
            if !UIImagePickerController.isSourceTypeAvailable(.camera){
                
                let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
                
                let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
                })
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            else{
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
               
                
                let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a photo source", preferredStyle: .actionSheet)
                
                actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                    imagePicker.sourceType = .camera
                        self.present(imagePicker, animated:  true, completion: nil)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Photo Libary", style: .default, handler: { (_) in
                    imagePicker.sourceType = .photoLibrary
                        self.present(imagePicker, animated:  true, completion: nil)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Never mind", style: .cancel, handler:  nil))
                
                self.present(actionSheet, animated:  true, completion: nil)
                
            }
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    private func updateViews(){
        guard isViewLoaded else {return}
        
        title = receipt?.name ?? "Add  New Receipt"
        receiptTitle.text = receipt?.name
        receiptNotes.text = receipt?.notes
        guard  let data = receipt?.imageData else {return}
        imageView.image = UIImage(data: data)
        
        
        let priority : ReceiptPriority
        if let receiprtPriority  = receipt?.priority {
            priority = ReceiptPriority(rawValue: receiprtPriority)!
        } else {
            priority = .nonnecessity
        }
        segmentControl.selectedSegmentIndex = ReceiptPriority.allCases.index(of : priority)!
    }
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var receiptTitle: UITextField!
    @IBOutlet weak var receiptNotes: UITextView!
    
    var receipt : Receipt?{
        didSet {
            updateViews()
        }
    }
let text = "Enter something about this receipt E.g #Walmart, #Barber, #Return"
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        receiptTitle.resignFirstResponder()
                return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        receiptNotes.resignFirstResponder()
        return true
    }
    
 
}
