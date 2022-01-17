//
//  ViewController.swift
//  NativeNetworkApiDemo
//
//  Created by Jat42 on 18/07/21.
//

import UIKit

class ViewController: UIViewController {

    var stringUrl = "https://jsonplaceholder.typicode.com/todos/1"
    //var stringUrl = "jsonpfxhdfhdflaceholderytyrty"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObserver()
        if NetworkRechability.isRechable {
            getData()
        }
    }
    
    func setObserver() {
        
        NetworkRechability.networkStatusHandler = { isConnected in
            print("Network Status:- \(isConnected)")
        }
    }
    
    func getData() {
        
        NetworkManager.makeNetworkRequest(
            url: stringUrl,
            method: .get,
            header: nil,
            defaultHeader: false,
            parameter: nil
        ) { response in
            
            switch response {
                
                case .success(let data):
                    
                    guard let jsonData = data else { return }
                    
                    do {
                        
                        let response = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                        print(response)
                        
                    } catch let e {
                        print("Data parsing error \(e)")
                    }
                    
                case .failure(let e):
                    // Show alert
                    print(e.localizedDescription)
                    
            }
            
        }
        
    }
    
        

}

