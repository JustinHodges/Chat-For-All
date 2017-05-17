//
//  ChatViewController.swift
//  Chat For All
//
//  Created by Justin Hodges on 5/17/17.
//  Copyright © 2017 Justin Hodges. All rights reserved.
//

import UIKit
import Alamofire
import PusherSwift
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var pusher : Pusher!
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    static let API_ENDPOINT = "http://localhost:4000";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputToolbar.contentView.leftBarButtonItem = nil
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        automaticallyScrollsToMostRecentMessage = true
        
        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
        
        let n = Int(arc4random_uniform(10000))
        
        senderId = "anonymous" + String(n)
        senderDisplayName = senderId
        
        listenForNewMessages()
    }
    
    private func listenForNewMessages() {
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        
        pusher = Pusher(key: "f0f1a7922824b61719d5", options: options)
        
        let channel = pusher.subscribe("chatroom")
        let _ = channel.bind(eventName: "new_message", callback: { (data: Any?) -> Void in
            
            if let data = data as? [String: AnyObject] {
                let author = data["sender"] as! String
                
                if author != self.senderId {
                    let text = data["text"] as! String
                    self.addMessage(senderId: author, name: author, text: text)
                    self.finishReceivingMessage(animated: true)
                }
            }
        })
        pusher.connect()
    }
    
    private func addMessage(senderId: String, name: String, text: String) {
        if let message = JSQMessage(senderId: senderId, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func postMessage(name: String, message: String) {
        let params: Parameters = ["sender": name, "text": message]
        
        Alamofire.request(ChatViewController.API_ENDPOINT + "/messages", method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
                
            case .success:
                // Succeeded, do something
                print("Succeeded")
            case .failure(let error):
                // Failed, do something
                print(error)
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        postMessage(name: senderId, message: text)
        addMessage(senderId: senderId, name: senderId, text: text)
        self.finishSendingMessage(animated: true)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
}
