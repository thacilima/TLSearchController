//
//  SearchViewController.swift
//  TLSearchController
//
//  Created by Thaciana Soares Goes de Lima on 11/25/16.
//  Copyright © 2016 Thaciana Soares Goes de Lima. All rights reserved.
//

import UIKit

protocol SearchViewControllerProtocol {
    func selectObject(object: AnyObject)
    func addAndSelectObject(objectDetail: String)
    func filterObjectsForEmptySearch() -> [AnyObject]
    func filterObjectsForSearch(text: String) -> [AnyObject]
    func getObjectDetail(object: AnyObject) -> String
    func getTitle() -> String
    func getNavigationBarTintColor() -> UIColor
    func getNavigationBarItensTintColor() -> UIColor
    func getNavigationBarCancelButtonTitle() -> String
    func getNavigationBarTranslucent() -> Bool
    func getSearchTextFieldPlaceholder() -> String
}

extension SearchViewControllerProtocol {
    
    func filterObjectsForEmptySearch() -> [AnyObject] {
        return []
    }
    
    func addAndSelectObject(objectDetail: String) {
        
    }
    
    func getNavigationBarTintColor() -> UIColor {
        return UIColor.black
    }
    
    func getNavigationBarItensTintColor() -> UIColor {
        return UIColor.white
    }
    
    func getNavigationBarCancelButtonTitle() -> String {
        return "Cancelar"
    }
    
    func getNavigationBarTranslucent() -> Bool {
        return false
    }
    
    func getSearchTextFieldPlaceholder() -> String {
        return "Digite pelo menos 3 caracteres"
    }
}

class SearchViewController: UIViewController {

    // MARK: Properties - View
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchAutoCompleteTableView: UITableView!
    @IBOutlet weak var navigationBarHeightLayoutConstraint: NSLayoutConstraint!
    
    // MARK: Properties - Instance
    
    fileprivate let addObjectOption: Bool
    fileprivate let minimumCaracterTypedForSearch: Int
    fileprivate var searchSelectionHandler: SearchViewControllerProtocol
    
    fileprivate var searchResult: [AnyObject] = []
    fileprivate var autoCompleteTimer = Timer()
    
    //MARK: Init
    
    init(delegate: SearchViewControllerProtocol, addObjectOption: Bool = false, minimumCaracterTypedForSearch: Int = 3, presentInPopover: Bool = false) {
        
        self.searchSelectionHandler = delegate
        self.addObjectOption = addObjectOption
        self.minimumCaracterTypedForSearch = minimumCaracterTypedForSearch
        
        super.init(nibName: "SearchViewController", bundle: nil)
        
        if presentInPopover {
            self.modalPresentationStyle = UIModalPresentationStyle.popover
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: 350.0)
        searchAutoCompleteTableView.estimatedRowHeight = 20.0
        searchAutoCompleteTableView.rowHeight = UITableViewAutomaticDimension
        
        navigationBar.items?.last?.title = searchSelectionHandler.getTitle()
        navigationBar.items?.last?.leftBarButtonItem?.title = searchSelectionHandler.getNavigationBarCancelButtonTitle()
        navigationBar.barTintColor = searchSelectionHandler.getNavigationBarTintColor()
        navigationBar.tintColor = searchSelectionHandler.getNavigationBarItensTintColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : searchSelectionHandler.getNavigationBarItensTintColor()]
        navigationBar.isTranslucent = searchSelectionHandler.getNavigationBarTranslucent()
        
        searchTextField.placeholder = searchSelectionHandler.getSearchTextFieldPlaceholder()
        
        searchResult = searchSelectionHandler.filterObjectsForEmptySearch()
        searchTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (popoverPresentationController?.arrowDirection != UIPopoverArrowDirection.unknown) {
            navigationBar.items?.last?.leftBarButtonItem = nil
            navigationBarHeightLayoutConstraint.constant = 44
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Action Methods
    
    @IBAction func cancelSearch() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func autoCompleteTimerAction() {
        if searchTextField.text!.characters.count == 0 {
            searchResult = searchSelectionHandler.filterObjectsForEmptySearch()
        }
        else if searchTextField.text!.characters.count >= minimumCaracterTypedForSearch {
            searchResult = searchSelectionHandler.filterObjectsForSearch(text: searchTextField.text!)
        }
        
        
        searchAutoCompleteTableView.reloadData()
    }
    
    // MARK: Instance Methods
    
    fileprivate func getTotalObjects() -> Int {
        var totalObjects = searchResult.count
        if addObjectOption {
            totalObjects += 1
        }
        
        return totalObjects
    }
    
    fileprivate func getObjectIndexForIndexPath(indexPath: IndexPath) -> Int {
        var objectIndex = indexPath.row
        if addObjectOption {
            objectIndex -= 1
        }
        
        return objectIndex
    }
}

// MARK: UITabBarDelegate

extension SearchViewController: UITabBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        // CODE HELP: This option make the top bar start behind the status bar. Wihtout this the status bar has a white background and the nav bar has its own background.
        return UIBarPosition.topAttached
    }
}

// MARK: UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        autoCompleteTimer.invalidate()
        autoCompleteTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(autoCompleteTimerAction), userInfo: nil, repeats: false)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        autoCompleteTimer.invalidate()
        searchTextField.resignFirstResponder()
        return true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchResult.count == 0 {
            tableView.isHidden = true
        }
        else {
            tableView.isHidden = false
        }
        
        return getTotalObjects()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var reusableCell = searchAutoCompleteTableView.dequeueReusableCell(withIdentifier: "SearchResultCell")
        if reusableCell == nil {
            reusableCell = UITableViewCell.init(style: .default, reuseIdentifier: "SearchResultCell")
        }
        
        guard let cell = reusableCell else {
            fatalError()
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.sizeToFit()
        
        if (indexPath.row == 0 && addObjectOption) {
            cell.textLabel?.text = "[ + ]"
        }
        else {
            let objectDetail = searchSelectionHandler.getObjectDetail(object: searchResult[getObjectIndexForIndexPath(indexPath: indexPath)])
            
            let attributedString = NSMutableAttributedString(string:objectDetail)
            let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
            
            let wordsInTextSearch = searchTextField.text!.components(separatedBy: " ")
            
            for word in wordsInTextSearch {
                
                let range = (objectDetail as NSString).range(of: word, options: [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive])
                attributedString.addAttributes(attrs, range: range)
            }
            
            cell.textLabel?.attributedText = attributedString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        autoCompleteTimer.invalidate()
        
        if (indexPath.row == 0 && addObjectOption) {
            searchSelectionHandler.addAndSelectObject(objectDetail: searchTextField.text!)
        }
        else {
            searchSelectionHandler.selectObject(object: searchResult[getObjectIndexForIndexPath(indexPath: indexPath)])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
