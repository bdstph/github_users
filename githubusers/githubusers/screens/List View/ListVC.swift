//
//  ListVC.swift
//  githubusers
//
//  Created by Brylle Seraspe on 12/18/20.
//

import UIKit
import CoreData

class ListVC: UIViewController {
    
    @IBOutlet weak var usersSearchBar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var list: [GHUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "GitHub Users"
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
        usersTableView.dataSource = self
        usersTableView.delegate = self
        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
        self.messageLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        
        //
        self.loadTable()
        self.showTableLabel()
        
        if self.list.count == 0 {
            self.fetchInitial()
        }
    }
    
    
    // MARK: - actions & selectors
    
    func fetchInitial() {
        // request data
        GHUserAService.shared.requestRecords(delegate: self)
    }
    
    func fetchNext() {
        // request data
        if let ghuser = list.last {
            GHUserAService.shared.requestRecords(delegate: self,
                                                 since: ghuser.sortID)
        }
    }
    
    func loadTable() {
        self.list = GHUser.allInstances()
        self.usersTableView.reloadData()
    }
    
    func showErrorMessage(_ message: String) {
        let duration: Double = 2
        
        UIView.animate(withDuration: duration) {
            self.messageLabel.text = message
            self.messageLabel.textColor = .systemRed
            self.messageLabel.textAlignment = .center
            self.messageLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.showTableLabel()
        }
    }
    
    func showTableLabel() {
        self.messageLabel.text = "     \(list.count) users"
        self.messageLabel.textColor = .label
        self.messageLabel.textAlignment = .left
        self.messageLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
    }
    
}

extension ListVC: GHUserAServiceProtocol {
    
    func didStart() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func didEnd(success: Bool, message: String?) {
        DispatchQueue.main.async {
            //
            self.view.isUserInteractionEnabled = true
            self.activityIndicatorView.isHidden = true
            self.activityIndicatorView.stopAnimating()
            
            //
            if let message = message {
                self.showErrorMessage(message)
            }
            else {
                //
                self.loadTable()
                self.showTableLabel()
            }
        }
    }
    
}

extension ListVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        let ghUSer: GHUser = list[indexPath.row]
        
        if let cellNormal = tableView.dequeueReusableCell(withIdentifier: "normal") as? NormalListTVCell {
            cell = cellNormal
            
            //
            //cellNormal.iconImageView
            cellNormal.userNameLabel.text = ghUSer.login
            cellNormal.detailsLabel.text = "\(ghUSer.sortID)"
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let islastIndex = indexPath.row == (self.list.count - 1)
        
        if islastIndex {
            print("last row = \(indexPath.row)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchNext()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    // MARK: - Scroll
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.list.count == 0 {
            self.fetchInitial()
        }
    }
    
}
