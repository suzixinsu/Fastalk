//
//  ViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 2/25/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import Photos


class ChatViewController: JSQMessagesViewController,UIBarPositioningDelegate {
    var chat: Chat?
    var userId = Auth.auth().currentUser!.uid
    let messagesRef = Constants.refs.databaseMessagesByChat
    let messagesByUserRef = Constants.refs.databaseMessagesByUser
    var userMessagesRef: DatabaseReference?
    var userChatRef: DatabaseReference?
    var friendChatRef: DatabaseReference?
    private var messagesRefHandle: DatabaseHandle?
    var messages = [JSQMessage]()
    let usersRef = Constants.refs.databaseUsers
    let groupChatsRef = Constants.refs.databaseGroups
    //var navigationBar : UINavigationBar?
    var fontSize = SettingsViewController.global.font
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()

    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    //Xin: for photo
    
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL:"gs://fastalkapp.appspot.com/")
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: DatabaseHandle?

    // TODO: - show username if group chat
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = chat?.receiverName
        self.userMessagesRef = messagesRef.child(chat!.id)
        self.userChatRef = Constants.refs.databaseChats.child(userId).child(chat!.id)
        let receiverId = self.chat?.receiverId
        if (receiverId != "group") {
            self.friendChatRef = Constants.refs.databaseChats.child(chat!.receiverId).child(chat!.id)
        }
        observeMessages()
        
        edgesForExtendedLayout = []
        //inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ChatViewController.tapToDismissKeyboard(_:)))
        view.addGestureRecognizer(tapRecognizer)
        addNavBar()
        topContentAdditionalInset = 60
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.userChatRef!.updateChildValues(["hasNewMessage" : false])
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Overriden Methods

    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        if fontSize == 0{
            fontSize = 20
        }
        let font = CGFloat(fontSize)
        cell.textView?.font = UIFont.systemFont(ofSize:font)
        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let receiverId = chat?.receiverId
        if (receiverId == "group") {
            return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
        }
        return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        let receiverId = chat?.receiverId
        if (receiverId == "group") {
            return messages[indexPath.item].senderId == senderId ? 0 : 15
        }
        return 0
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        print("start didPressSend")
        let itemRef = userMessagesRef!.childByAutoId()
        let date = getDate()
        let receiverName = chat?.receiverName
        let receiverId = chat?.receiverId
        let messageItem = [
            "senderId": self.senderId,
            "senderName": self.senderDisplayName,
            "receiverName": receiverName!,
            "receiverId": receiverId!,
            "text": text!,
            "timeStamp": date
        ]
        
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        messagesByUserRef.child(userId).child(itemRef.key).setValue(messageItem)
        if (receiverId != "group") {
            messagesByUserRef.child(receiverId!).child(itemRef.key).setValue(messageItem)
        }
        
        //update chat
        self.userChatRef!.updateChildValues(["timeStamp" : date])
        self.userChatRef!.updateChildValues(["lastMessage" : text])
        if (receiverId != "group") {
            let chatItem = [
                "lastMessage" : text,
                "receiverId" : self.senderId,
                "receiverName" : self.senderDisplayName,
                "timeStamp" : date,
                "hasNewMessage": true
                ] as [String : Any]
            self.friendChatRef?.setValue(chatItem)
        } else {
            self.groupChatsRef.child(self.chat!.id).updateChildValues(["timeStamp" : date])
            self.groupChatsRef.child(self.chat!.id).updateChildValues(["lastMessage" : text])
            self.groupChatsRef.child(self.chat!.id).updateChildValues(["hasNewMessage" : true])
        }
        print("end didPressSend")
        finishSendingMessage()
    }
 
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            
            picker.sourceType = UIImagePickerControllerSourceType.camera
        }else{
            print("checkpoint1")
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        present(picker, animated: true, completion: nil)
        print("End didPressAccessoryButton")
    }
    // MARK: - Private Methods
    private func observeMessages() {
        let messageQuery = userMessagesRef!.queryLimited(toLast:25)
        messagesRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String?, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.count > 0 {
                print("show message")
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            }
            else if let id = messageData["senderId"] as String?,
                let photoURL = messageData["photoURL"] as String? { // 1
                print("show photo")
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        print(photoURL)
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
                // We can also use the observer method to listen for
                // changes to existing messages.
                // We use this to be notified when a photo has been stored
                // to the Firebase Storage, so we can update the message data

                print("end show photo")
            }
            else {
                print("Error! Could not decode message data")
            }
        })
        self.updatedMessageRefHandle = self.userMessagesRef?.observe(.childChanged, with: { (snapshot) in
        //self.updatedMessageRefHandle = self.messagesRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            //MARK:一个新的问题诞生了
            print("update message ref handle")
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                print("messageData")
                if let mediaItem = self.photoMessageMap[key] { // 3
                    print("mediaItem")
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
        print("end observe")
    }
    
    private func getDate() -> String{
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm MM/dd/yy"
        let convertedDate = dateFormatter.string(from: currentDate)
        return convertedDate
    }

    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    @objc func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
  
    func addNavBar() {
        addCover()
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height:50)) // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.prefersLargeTitles = true
        navigationBar.barTintColor = UIColor(named: navColor[Config.colorScheme()])
        navigationBar.tintColor = UIColor.white
        
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        //navigationBar.titleTextAttributes
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = chat?.receiverName
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Back", style:   .plain, target: self, action: #selector(btn_clicked(_:)))
        let rightButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btn_clicked(_:)))
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    }
    func addCover(){
        let squarePath = UIBezierPath()
        squarePath.move(to: CGPoint(x: 0, y: 0))
        squarePath.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 0))
        squarePath.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 20))
        squarePath.addLine(to: CGPoint(x: 0, y: 20))
        squarePath.close()
        let square = CAShapeLayer()
        square.path = squarePath.cgPath
        square.fillColor = UIColor(named: navColor[Config.colorScheme()])?.cgColor
        self.view.layer.addSublayer(square)
    }
    @objc func btn_clicked(_ sender: UIBarButtonItem) {
        // Do something
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let initialView = storyboard.instantiateViewController(withIdentifier: "startNavigation")
        self.present(initialView, animated: true, completion: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Photo
    func sendPhotoMessage() -> String? {
        print("start sendPhotoMessage()")
        //MARK:这里可能搞的有点晕
        //let itemRef = messagesRef.childByAutoId()
        
        
        let itemRef = userMessagesRef!.childByAutoId()
        let date = getDate()
        let receiverName = chat?.receiverName
        let receiverId = chat?.receiverId
        let hint = "[Photo]"
        let messageItem = [
            
            "senderId": self.senderId,
            "senderName": self.senderDisplayName,
            "receiverName": receiverName!,
            "receiverId": receiverId!,
            "text": "",
            "photoURL": imageURLNotSetKey,
            "timeStamp": date
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        //??
        messagesByUserRef.child(userId).child(itemRef.key).setValue(messageItem)
        if(receiverId != "group"){
            messagesByUserRef.child(receiverId!).child(itemRef.key).setValue(messageItem)
        }
        //update Chat
        self.userChatRef!.updateChildValues(["timeStamp" : date])
        self.userChatRef!.updateChildValues(["lastMessage" : hint])
        
        if(receiverId != "group"){
            let chatItem = [
                "lastMessage" : hint,
                "receiverId" : self.senderId,
                "receiverName" : self.senderDisplayName,
                "timeStamp" : date,
                "hasNewMessage" : true
                ] as [String : Any]
        }else{

            self.groupChatsRef.child(self.chat!.id).updateChildValues(["timeStamp" : date])
            self.groupChatsRef.child(self.chat!.id).updateChildValues(["lastMessage" : hint])
            self.groupChatsRef.child(self.chat!.id).updateChildValues(["hasNewMessage" : true])
        }
        //end update
        finishSendingMessage()
        print("check finish sendings")
        
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String){
        print("setImageURL()")
        //MARK: this is the problem
        //let itemRef = messagesRef.child(key)
        let itemRef = userMessagesRef?.child(key)
        itemRef?.updateChildValues(["photoURL":url])
        print("END setImageURL()")
    }


    //TODO: display photo
    //store theJSQPhotoMediaItem in the new property if the image key hasn't yet been set
    //retrive it and update the message when the image is set later on
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem){
        print("START addPhotoMessage")
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem)//??id?
        {
            print("append a photo")
            messages.append(message)
            
            if(mediaItem.image == nil){
                print("key:\(key)")
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
            //print
        }
        print("END addPhotoMessage")
    }

    //fetch the image data from the fire base storage to display it in the ui
    //TODO: fetchimagedataaturl
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem,
                                     clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // get a reference to the stored image
        print("fetch data")
        let storageRef = Storage.storage().reference(forURL: photoURL)
        // 2 get the image data from the storage
        storageRef.getData(maxSize: INT64_MAX) { data, error in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            // 3
            storageRef.getMetadata { metadata, metadataErr in
//            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4 if the metadata suggests that the images is a gif you use
                //a category on uiimage that was pulled in via the swiftgiforigin cocapod
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gif(data: data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                print("reload after getting data")
                self.collectionView.reloadData()
                
                // 5 remove the key from the photomessagemap nowthat you've fetched the image data
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            }
        }
// added delegate method
    
    }
 
    deinit {
        if let refHandle = messagesRefHandle{
            messagesRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle{
            messagesRef.removeObserver(withHandle: refHandle)
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        print("START :image Picker")
        checkPermission()
        //picker.dismiss(animated: true, completion: nil)
        
        print(info[UIImagePickerControllerReferenceURL])
        print(info[UIImagePickerControllerPHAsset] )
        
            if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL{
            //Handle picking a photo from the Photo Librar
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl],
                                                options: nil)
            print("checkpoint2")
           // let assets = PHAsset.fetchassets
            let asset = assets.firstObject
            print("checkpoint3")
            if let key = sendPhotoMessage(){
                //get the file url for the image
                print(key)
                asset?.requestContentEditingInput(with: nil, completionHandler: {(contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    print("checkpoint4")
                    //create a unique path based on the user's unique id and the current time
                    let path = "\(Auth.auth().currentUser!.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    //save the image file to firebase storage
                    print("path:" + path)
                    //MARK: 这整个extension都有毛病
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil){metadata, error in
                        if let error = error{
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        else{
                            print("else and put data")
                            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                            print("set ImageURL at the end of photoReferendeUrl")
                        }
                    }
                })
            }
            print("end if")
        }else{
            //Handle picking a Photo from the Camera -TODO
            //grab the image from the info dictionary
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            //call the method to save the fake image url to firebase
            if let key = sendPhotoMessage(){
                print("masaka")
                //get the jpeg representation to the poto, ready to be sent to firebase storage
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                //create a unique url
                let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate*1000)).jpg"
                //create a storagemetadate obj and set the metadata to image/jpeg
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                //save the photo to storage
                
                storageRef.child(imagePath).putData(imageData!, metadata: metadata) {
                    (metadata,error) in
                    if let error = error{
                        print("Error uploading photo: \(error)")
                        return
                    }
                    //once the image has been saved, you call set imageurl again
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
            print("end else")
        }
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        dismiss(animated: true, completion: nil)
        print("End Phto or Camera")
    }
    
    @objc internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: print("Access is granted by user")
        case .notDetermined: PHPhotoLibrary.requestAuthorization({
            (newStatus) in print("status is \(newStatus)")
            if newStatus == PHAuthorizationStatus.authorized { print("success") }
            })
            case .restricted:
                print("User do not have access to photo album.")
            case .denied:
                print("User has denied the permission.")
            }
        }

}

