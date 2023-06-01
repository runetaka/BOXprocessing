//
//  JobListTableViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/12/22.
//

import UIKit
import FirebaseFirestore
import Nuke

class JobListTableViewController:UIViewController{
    
    @IBOutlet weak var searchButton: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var refresh =  UIRefreshControl()
    var jobs : [Job] = []
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "JobListTableViewCell", bundle: nil), forCellReuseIdentifier: "jobCell")
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        getJobList()
        
        searchButton.isUserInteractionEnabled = true
        let search = UITapGestureRecognizer(target: self, action: #selector(tappedSearchButton))
        searchButton.addGestureRecognizer(search)
        
        searchButton.cornerRadius = searchButton.frame.height / 2
        searchButton.layer.masksToBounds = false
        searchButton.layer.shadowColor = UIColor.black.cgColor
        searchButton.layer.shadowOpacity = 0.3
        searchButton.layer.shadowRadius = 4
        searchButton.layer.shadowOffset = .zero
        
    }
    
    @objc func tappedSearchButton(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    @objc func refreshTableView(){
        self.getJobList()
    }
    
    func getJobList(){
        self.jobs = []
        Firestore.firestore().collection("companies").limit(to: 30).getDocuments { snapshots, error in
            if let error = error{
                print(error)
                return
            }
            
            guard let documents = snapshots?.documents else{return}
            for document in documents {
                let job = Job(dic: document.data())
                self.jobs.append(job)
                self.tableView.reloadData()
            }
        }
    }
    
}

extension JobListTableViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobListTableViewCell
        if jobs.count > indexPath.row{
            let job = jobs[indexPath.row]
            cell.title.text = job.title
            cell.area.text = job.area
            cell.salary.text = job.salary
            cell.companyName.text = job.companyName
            if let urlString = job.companyImages?.first{
                let url = URL(string: urlString)
                loadImage(with: url, into: cell.companyImageView) { result in
                }
            }
        }
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "JobDetailView", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
        
        if jobs.count > indexPath.row{
            let job = jobs[indexPath.row]
            vc.job = job
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
