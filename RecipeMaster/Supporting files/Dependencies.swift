//
//  Dependencies.swift
//  RecipeMaster
//
//  Created by Sudhakar Dasari on 25/07/19.
//  Copyright © 2019 sudhakar. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    
    func openSFSafariVC(WithURL url:String?) {
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: NSURL(string: url ?? "")! as URL, configuration: config)
        self.present(vc, animated: true)
        
    }
    
    //MARK:-  UIActivityIndicatorView
    /**
     Property used to identify the activity indicator. Default valye is `999999`
     but this can be overridden.
     */
    public var activityIndicatorTag: Int { return 999999 }
    
    /**
     Creates and starts an UIActivityIndicator in any UIViewController
     Parameter style: `UIActivityIndicatorViewStyle` default is .Gray
     Parameter location: `CGPoint` if not specified the `view.center` is applied
     */
    public func startActivityIndicator(_ style: UIActivityIndicatorView.Style = .gray, location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center
        
        DispatchQueue.main.async(execute: {
            let activityIndicator = UIActivityIndicatorView(style: style)
            activityIndicator.tag = self.activityIndicatorTag
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        })
    }
    
    /**
     Stops and removes an UIActivityIndicator in any UIViewController
     */
    public func stopActivityIndicator() {
        
        DispatchQueue.main.async(execute: {
            if let activityIndicator = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        })
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String?) {
        
        //let messageLabel = UILabel(frame: CGRect(x: CGFloat(self.bounds.size.width / 2), y: CGFloat(self.bounds.size.height / 2), width: CGFloat(self.bounds.size.width - 10), height: CGFloat(20)))
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        //messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
}


extension UIView {
    
    func applyCornerRadius(radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func circleView () {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}
