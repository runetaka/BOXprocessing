//
//  SelectPurposeTableViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2023/04/29.
//


import UIKit
import AlgoliaSearchClient
//import InstantSearch
import FirebaseFirestore
import SwiftUI
import TaggerKit

struct Item: Codable {
  let hashTag: [String]
}

enum Mode{
    case searchGroup
    case searchPost
    case group
    case post
    case addGroup
}

class SelectPurposeTableViewController :UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource, TKCollectionViewDelegate{
    
    
    @IBOutlet weak var hashTagScrollView: UIScrollView!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
//    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hashTagCountLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
//    @IBOutlet weak var tableView: UITableView!
    
    //    let searcher = HitsSearcher(appID: "L2JV1D1FHL",
//                                apiKey: "63aedc364532708995d34208ffa8e16e",
//                                indexName: "group")
//    var post : Post?
    
    var cache : [String:[Facet]] = [:]
    var results :[Hit<JSON>] = []
    var selectedTags : [String] = []
    
    var tagCollection = TKCollectionView()
    
    let client = SearchClient(appID: "2JAYQSHTSY", apiKey: "1b0e4f7a6529f190da4bddc29a4a7c25")
    var searchText : String = ""
    var timer : Timer?
    
    var mode : Mode = .searchPost
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
//      searchController.isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tagCollection.receiver = tagCollection
        tagCollection.action = .removeTag
        tagCollection.customBackgroundColor = .init(hex: "ED7864")
        tagCollection.customFont = .boldSystemFont(ofSize: 14)
        tagCollection.delegate = self
        add(tagCollection, toView: selectedView)
        setupView()
        
        self.searchBar.delegate  = self
        //検索の場合
        let dismissButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(tappedBackButton))
        dismissButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = dismissButton
        searchFacets()
        setupNextButton()
        
    }
    
    func setupNextButton(){
        doneButton.layer.shadowColor = UIColor.black.cgColor
        doneButton.layer.shadowRadius = 4
        doneButton.layer.shadowOpacity = 0.3
        doneButton.layer.shadowOffset = .zero
        doneButton.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
    }
    
    func setupView(){
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "tags")
        dispatchQueue.async(group:dispatchGroup) {
                //検索、グループのタグ設定
                let tags = self.selectedTags.reduce(into: [String](), { partialResult, text in
                    let string = "#" + text
                    partialResult.append(string)
                })
                self.tagCollection.tags = tags
                DispatchQueue.main.async{
                    self.hashTagCountLabel.text = "選択中のキーワード : \(self.selectedTags.count) / 5"
//                    if tags.count >= 5{
//                        self.tableView.allowsSelection = false
//                    }else{
//                        self.tableView.allowsSelection = true
//                    }
                }
            
        }
        dispatchQueue.async(group: dispatchGroup){
            DispatchQueue.main.async {
                let collectionWidth = self.tagCollection.tagCellLayout.tagFullLength
                self.scrollViewWidth.constant = collectionWidth
                if collectionWidth > self.hashTagScrollView.frame.width{
                    self.hashTagScrollView.setContentOffset(CGPoint(x: collectionWidth - self.hashTagScrollView.frame.width, y: 0), animated: true)
                }
            }
        }
    }
    
    @objc func tappedDoneButton(){
        
            let nav = self.navigationController
            let vc = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! SearchTableViewController
            
            vc.selectedTags = self.selectedTags
            vc.beforeQuery?.hashTags = self.selectedTags
            vc.tagIsAdded = false
            self.navigationController?.popViewController(animated: true)
            
    }
    
    
    @objc func tappedBackButton(){
            self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func tappedView(){
        searchBar.endEditing(true)
    }
    
    @objc func textDidChange(){
        
    }
    
    @objc private func searchFacets(){
        
        //@TODO　algolia 全文検索
        
        var groupIndex : Index
        var querySuggestionIndex :Index
        querySuggestionIndex = client.index(withName: "jobs_query_suggestions")
        groupIndex = client.index(withName: "jobs")
        
        
        var query = Query(searchText)
//        query.facets = ["context"]
        
        query = query.set(\.maxFacetHits, to: 20)
        querySuggestionIndex.search(query: query) {  result in
            
            print(result)
//                self.currentPage += 1
            if case .success(let response) = result {
            
                let hits  = response.hits
//                self.results = hits
                print("hits",hits.count)
                DispatchQueue.main.async {
//                    if hits.isEmpty{
////                        self.noGroupView.isHidden = false
//                    }else{
////                        self.noGroupView.isHidden = true
//                    }
//                    for hit in hits{
//                        guard let object = hit.object.object(),
//                              let data = try? JSONSerialization.data(withJSONObject: object),
//                              let job = try? JSONDecoder().decode(Job.self, from: data) else{continue}
//                        self.results.append(job)
//
//                    }
                    self.tableView.reloadData()

                }
            }else if case .failure(let error) = result{
                print("error:",error)
            }
            
//            let data = try! JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)
//            let job = try! JSONDecoder().decode(Job.self, from: data)
//                         print(response)
        }
//        }
//        }
//        groupIndex.searchForFacetValues(of: "context", matching: searchText,applicableFor: query, completion: {
//            (res) in
//            print(res)
//
//            if case .success(let response) = res {
//                let facets = response.facetHits
//                self.results = facets
//                self.cache[self.searchText] = facets
//                print("hits",facets.count)
//                if let index = self.results.firstIndex(where: {$0.value == self.searchText}){
//                    //検索結果に一致するタグがある場合
//                }else{
//                    //ない場合、tableViewの一行目に検索したワードを入れる
//                    if !(self.searchText.isEmpty){
//                        self.results.insert(Facet(value: self.searchText, count: 0), at: 0)
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//
//            }
//        })
        
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 15
        if (searchBar.text?.count ?? 0) + text.count > maxLength{
            return false
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                guard let searchText = searchBar.text,!(searchText.isEmpty) else{return}
            self.searchText = searchText
                self.checkCache()
            }
            return true
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
        self.searchText = searchText
        checkCache()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else{return}
        self.searchText = searchText
        self.checkCache()
    }
    
    @objc func checkCache(){
//        if let cachedFacets = cache[searchText],!(cachedFacets.isEmpty){
//            self.results = cachedFacets
//            self.timer?.invalidate()
//            if let index = self.results.firstIndex(where: {$0.value == self.searchText}){
//                //検索結果に一致するタグがある場合
//            }else{
//                //ない場合、tableViewの一行目に検索したワードを入れる
//                if !(self.searchText.isEmpty){
//                    self.results.insert(Facet(value: self.searchText, count: 0), at: 0)
//                }
//            }
//            self.tableView.reloadData()
//
//            print(cachedFacets)
//        }else{
//            self.searchTimer()
//        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let text = searchBar.text else{return}
        self.searchText = text
        if let timer = timer {
            timer.fire()
        }else{
            self.checkCache()
        }
    }
    
    func searchTimer(){
        //テキスト入力後0.5秒間入力がない場合検索する
        //連続入力時に検索を行わないため
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchFacets), userInfo: nil, repeats: false)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purposeCell", for: indexPath)
//        cell.textLabel?.text = hitsSource?.hit(atIndex: indexPath.row)?.groupArea
        let valueLabel = cell.viewWithTag(1) as! UILabel
        let countLabel = cell.viewWithTag(2) as! UILabel
        let facet = results[indexPath.row]
        let matchWords = facet.highlightResult?.value?.matchedWords
        print("matchWords:\(matchWords)")
//        let count = facet.count
//        valueLabel.text = facet.value
//        countLabel.text = "\(count)件"
        return cell
        
    }
    
//    @objc func addNewTag(){
//
//        if selectedTags.contains(tag){
//            return
//        }else{
//            results.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .right)
//            self.selectedTags.append(tag)
//            let string = "#" + tag
//            self.tagCollection.addNewTag(named: string)
//            let collectionWidth = self.tagCollection.tagCellLayout.tagFullLength
//            self.scrollViewWidth.constant = collectionWidth
//            if collectionWidth > self.hashTagScrollView.frame.width{
//                self.hashTagScrollView.setContentOffset(CGPoint(x: collectionWidth - self.hashTagScrollView.frame.width, y: 0), animated: true)
//            }
//            self.hashTagCountLabel.text = "選択中のハッシュタグ : \(selectedTags.count) / 5"
//            if selectedTags.count >= 5{
//                self.tableView.allowsSelection = false
//            }else{
//                self.tableView.allowsSelection = true
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let tag = results[indexPath.row].value
        let tag = results[indexPath.row]
//            if selectedTags.contains(tag){
//                return
//            }else{
//                results.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .right)
//                self.selectedTags.append(tag)
//                let string = "#" + tag
//                self.tagCollection.addNewTag(named: string)
//                let collectionWidth = self.tagCollection.tagCellLayout.tagFullLength
//                self.scrollViewWidth.constant = collectionWidth
//                if collectionWidth > self.hashTagScrollView.frame.width{
//                    self.hashTagScrollView.setContentOffset(CGPoint(x: collectionWidth - self.hashTagScrollView.frame.width, y: 0), animated: true)
//                }
//                self.hashTagCountLabel.text = "選択中のハッシュタグ : \(selectedTags.count) / 5"
//                if selectedTags.count >= 5{
//                    self.tableView.allowsSelection = false
//                }else{
//                    self.tableView.allowsSelection = true
//                }
//            }
    }
    
    
    func tagIsBeingAdded(name: String?) {
        
    }
    
    func tagIsBeingRemoved(name: String?) {
        
        guard var name = name else {return}
        if name.first == "#"{
            name.removeFirst()
        }
            self.selectedTags.removeAll(where: {$0 == name})
            let collectionWidth = self.tagCollection.tagCellLayout.tagFullLength
            self.scrollViewWidth.constant = collectionWidth
//            self.hashTagCountLabel.text = "追加したハッシュタグ : \(post?.hashTag.count ?? 0) / 5"
//            self.tableView.allowsSelection = post?.hashTag.count ?? 0 < 5 ? true : false
 
        
    }

}


