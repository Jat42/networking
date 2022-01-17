//
//  NetworkActivityIndicator.swift
//  NetworkManager
//
//  Created by Jat42 on 26/07/21.
//

import UIKit


class ActivityIndicator: NSObject {
    
    let loadingText = LoadingLabel()
    
    private var windowScene : UIWindowScene? {
        get {
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
    }
    
    private var sceneDelegate: SceneDelegate? {
        get {
            windowScene?.delegate as? SceneDelegate
        }
    }
    
    private var window: UIWindow? {
        get {
            sceneDelegate?.window
        }
    }
    
    // Current working gif method
    
    func showLoadingView(isInteractionAllow: Bool = false) {
        
        for view in (self.window?.subviews)! {
            if view.tag == 4444{
                return
            }
        }
        
        // UIView Background View //
        
        let backgroundView = UIView()
        
        // UIView Card View //
        
        let cardView = UIView(
            frame: CGRect.init(
                x: 0,
                y: 0,
                width: 110,
                height: 110
            )
        )
        
        // cardView Formatting
        cardView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9803921569, blue: 0.9843137255, alpha: 1)
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowColor = UIColor.lightGray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowRadius = 1
        
        // Activity Indicator
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.color = #colorLiteral(red: 0.1254901961, green: 0.5803921569, blue: 0.9607843137, alpha: 1)
        
        cardView.addSubview(activityIndicator)
        
        if isInteractionAllow {
            
            cardView.tag = 4444
            
            cardView.center = self.window!.center
            
        } else {
            
            backgroundView.frame = window?.bounds ?? .zero
            
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            
            backgroundView.tag = 4444
            
            cardView.center = backgroundView.center
            
            backgroundView.addSubview(cardView)
        }
        
//        let imageView = UIImageView()
//
//        imageView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: view.bounds.width - 184,
//            height: 7
//        )
//        imageView.layer.cornerRadius = 3
//        imageView.layer.masksToBounds = true
//        imageView.center = cardView.center
//        //imageView.image = UIImage.gifImageWithName("loader", delayMicroSeconds: Configuration.gifAnimationDelay)
//
//        cardView.addSubview(imageView)
        
        //view.addSubview(imageView)
        
        // UILabel //

        loadingText.frame = CGRect.init(
            x: 10,
            y: (cardView.frame.height-20),
            width: cardView.frame.width,
            height: 15
        )
        
        loadingText.textAlignment = .left
        loadingText.text = "Please wait"
        loadingText.font = UIFont.init(name: "Metropolis-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        
        cardView.addSubview(loadingText)
        
        self.window?.addSubview(isInteractionAllow ? cardView : backgroundView)
        
        loadingText.start()
    }
    
    func hideLoadingView() {
        //loadingText.stop(withText: "")
        for view in (self.window?.subviews)! {
            if view.tag == 4444 {
                view.removeFromSuperview()
            }
        }
    }
    
}
