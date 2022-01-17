//
//  Loading Animation.swift
//  NetworkManager
//
//  Created by Jat42 on 29/07/21.
//

import UIKit

class LoadingLabel: UILabel {
    var timer: Timer?
    let states = [" ",".", "..", "..."]
    var currentState = 0
    
    func start() {
        stop(withText: "")
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stop(withText text: String) {
        timer?.invalidate()
        timer = nil
        
        self.text = text
    }
    
    @objc func update() {
        text = "\(self.text ?? "Please wait") " + states[currentState]
        currentState = (currentState + 1) % states.count
    }
}
