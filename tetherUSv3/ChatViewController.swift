//
//  ChatViewController.swift
//  tetherUSv3
//
//  Created by Scott on 3/9/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    // MARK: Properties
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var chatRef: Firebase!
    var usersTypingQuery: FQuery!
    
    var userIsTypingRef: Firebase!
    private var localTyping = false
    var isTyping: Bool {
        get{
            return localTyping
        }
        set{
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TetherUs Chat"
        setupBubbles()
        
        // no avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        chatRef = Firebase(url: FirebaseConstants.TETHERCHAT)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeChatMessages()
        observeTyping()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = chatRef.childByAutoId()
        let chatItem = [
            "text": text,
            "senderId": senderId
        ]
        itemRef.setValue(chatItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = (textView.text != "")
    }
    
    func addMessage(id: String, text: String){
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    private func observeTyping(){
        let typingIndicatorRef =  Firebase(url: FirebaseConstants.BASE).childByAppendingPath("typingIndicator")
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value, withBlock: {(snapshot) in
            if snapshot.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = (snapshot.childrenCount > 0)
            self.scrollToBottomAnimated(true)
        })
    }
    
    private func observeChatMessages(){
        
        let messagesQuery = chatRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            let id = snapshot.value.objectForKey("senderId") as! String
            let text = snapshot.value.objectForKey("text") as! String
            
            self.addMessage(id, text: text)
            
            self.finishReceivingMessage()
        })
    }
    
    private func setupBubbles(){
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
}
