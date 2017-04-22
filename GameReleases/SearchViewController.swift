//
//  ViewController.swift
//  GameReleases
//
//  Created by Corey McCourt on 9/22/16.
//  Copyright © 2016 Corey McCourt. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftMoment

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FilterViewControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let resPerPage = 20
    var currentOffset = 0
    var moreAvailable = true
    
    var dataDict = [String: [GBGame]]()
    var sections = [String]()
    var selectedGame = GBGame()
    var dateString: String = ""
    var endDateString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        dateString = moment().format("YYYY-MM-dd")
        endDateString = moment().add(1, .Months).format("YYYY-MM-dd")
        getData(from: dateString, to: endDateString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDict[sections[section]]!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let game = dataDict[sections[section]]![row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let nameLabel = cell.viewWithTag(100) as? UILabel {
            nameLabel.text = game.name
        }
        
        if (game.thumbUrl != nil), let imageView = cell.viewWithTag(200) as? UIImageView, let url = game.thumbUrl {
//            let data = NSData(contentsOf: url as URL)
//            imageView.image = UIImage(data: data as! Data)
            imageView.imageFromServerURL(urlString: url.absoluteString!)
        }
        
        if (game.date != nil), let dateLabel = cell.viewWithTag(300) as? UILabel {
            dateLabel.text = game.date
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        
        if let dateButton = cell?.viewWithTag(100) as? UIButton {
            dateButton.setTitle(sections[section], for: .normal)
            dateButton.contentHorizontalAlignment = .left
            dateButton.addTarget(self, action: #selector(headerBtnAction), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        selectedGame = dataDict[sections[section]]![row]
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height {
            getData(from: dateString, to: endDateString, getMore: true)
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let vc = segue.destination as! DetailViewController
            vc.game = selectedGame
        }
        else if segue.identifier == "filterSegue" {
            let vc = segue.destination as! FilterViewController
            vc.date = moment(dateString)!.date
            vc.delegate = self
        }
    }
    
    // Mark: - Actions
    func headerBtnAction(sender: UIButton) {
        if let date = sender.titleLabel?.text {
            dateString = date
        }
        performSegue(withIdentifier: "filterSegue", sender: self)
    }

    // MARK: - Filter View Controller Delegate
    func setFilterDate(date: Date) {
        moreAvailable = true
        let dateString = moment(date).format("YYYY-MM-dd")
        let endDateString = moment(date).add(2, .Years).format("YYYY-MM-dd")
        getData(from: dateString, to: endDateString)
    }
    
    // Mark: - API requests
    func getData(from dateString: String, to endDateString: String, getMore: Bool = false) {
        // Only get more results if there are results available
        
        guard moreAvailable else {
            print("No more available data")
            return
        }
        
        if getMore {
            self.currentOffset += self.resPerPage
        }
        else {
            self.dataDict.removeAll()
            self.sections.removeAll()
            self.currentOffset = 0
        }
        
        GiantBombAPI.games(date: dateString, endDate: endDateString, limit: resPerPage, offset: currentOffset) { (results) in
            guard let data = results, data.count > 0 else {
                self.moreAvailable = false
                return
            }
            
            for res in data {
                if let date = res.date {
                    
                    // Add new date
                    if !self.sections.contains(date) {
                        self.sections.append(date)
                        self.dataDict[date] = [GBGame]()
                    }
                    
                    // Add data
                    self.dataDict[date]!.append(res)
                }
            }
            self.tableView.reloadData()
            self.tableView.setContentOffset(.zero, animated: false)
        }
    }
}

