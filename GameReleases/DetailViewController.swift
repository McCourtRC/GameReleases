//
//  DetailViewController.swift
//  GameReleases
//
//  Created by Corey McCourt on 10/12/16.
//  Copyright © 2016 Corey McCourt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var game = GBGame()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - TableView
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let imageView = cell.viewWithTag(100) as? UIImageView, let url = game.mediumUrl {
            let data = NSData(contentsOf: url as URL)
            imageView.image = UIImage(data: data as! Data)
        }
        
        if let titleLabel = cell.viewWithTag(200) as? UILabel {
            titleLabel.text = game.name
        }
        
        if let dateLabel = cell.viewWithTag(300) as? UILabel {
            dateLabel.text = game.date
        }
        
        if let followBtn = cell.viewWithTag(400) as? UIButton {
            followBtn.addTarget(self, action: #selector(followBtnAction), for: .touchUpInside)
        }
        
        if let deckLabel = cell.viewWithTag(500) as? UILabel {
            deckLabel.text = game.deck
        }
        
        return cell
    }
    
    func followBtnAction() {
        print("Follow Button")
    }


}
