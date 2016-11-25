//
//  ViewController.swift
//  TLSearchController
//
//  Created by Thaciana Soares Goes de Lima on 11/25/16.
//  Copyright © 2016 Thaciana Soares Goes de Lima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let objectsForSearch = ["Orange", "Watermelon", "Banana"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func searchFruits(_ sender: Any) {
        
        let vc = SearchViewController.init(delegate: self)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func searchFruitsInPopover(_ sender: UIButton) {
        
        let vc = SearchViewController.init(delegate: self, presentInPopover: true)
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.delegate = self
        popover.permittedArrowDirections = .up
        
        present(vc, animated: true, completion:nil)
    }
    
}

extension ViewController: SearchViewControllerProtocol {
    
    func selectObject(object: AnyObject) {
        let objectString = object as! String
        print(objectString)
    }
    
    func filterObjectsForSearch(text: String) -> [AnyObject] {
        let filtered = objectsForSearch.filter({ $0.lowercased().contains(text.lowercased()) })
        return filtered.map { $0 as AnyObject }
    }
    
    func getObjectDetail(object: AnyObject) -> String {
        let objectString = object as! String
        return objectString
    }
    
    func getTitle() -> String {
        return "Search Fruits"
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    
}
