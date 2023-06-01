//
//  QuerySuggestion.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2023/05/28.
//

import Foundation
import InstantSearch
import TaggerKit

class SuggestionsTableViewController: UITableViewController, HitsController, SearchBoxController {
    
    var onQueryChanged: ((String?) -> Void)?
    var onQuerySubmitted: ((String?) -> Void)?
    
    public var hitsSource: HitsInteractor<QuerySuggestion>?{
        didSet{
            self.cache[searchText] = self.results
        }
    }
    
    let cellID = "сellID"
    
    var selectedSuggestion : String?
    
    var searchText :String = ""
    var cache : [String:[QuerySuggestion]] = [:]
    var results : [QuerySuggestion] = []
    var timer : Timer?
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
        tableView.register(SearchSuggestionTableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setQuery(_ query: String?) {
        print("query",query)
        
    }
    
//    @objc func checkCache(){
//        if let cachedSuggestion = cache[searchText],!(cachedSuggestion.isEmpty){
//            self.results = cachedSuggestion
//            self.timer?.invalidate()
//            if let index = self.results.firstIndex(where: {$0.query == self.searchText}){
//                //検索結果に一致するタグがある場合
//            }else{
//                //ない場合、tableViewの一行目に検索したワードを入れる
//                if !(self.searchText.isEmpty){
//
//                    self.results.insert(QuerySuggestion(query: self.searchText, highlighted: searchText, popularity: 0), at: 0)
//                }
//            }
//            self.tableView.reloadData()
//
//            print(cachedSuggestion)
//        }else{
//            let hits = hitsSource?.hits
//            self.searchTimer()
//        }
//    }
//
//    func searchTimer(){
//        //テキスト入力後0.5秒間入力がない場合検索する
//        //連続入力時に検索を行わないため
//        self.timer?.invalidate()
//        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchSuggestions), userInfo: nil, repeats: false)
//    }
//
//    @objc func searchSuggestions(){
//
//    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hitsSource?.numberOfHits() ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? SearchSuggestionTableViewCell else { return .init() }
        
        if let suggestion = hitsSource?.hit(atIndex: indexPath.row) {
            cell.setup(with: suggestion)
            cell.didTapTypeAheadButton = {
                self.onQueryChanged?(suggestion.query)
            }
        }else{
            
        }
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let suggestion = hitsSource?.hit(atIndex: indexPath.row) else { return }
        self.selectedSuggestion = suggestion.query
        onQuerySubmitted?(suggestion.query)
        
        
    }
    
}



class SearchSuggestionTableViewCell: UITableViewCell {
    
    var didTapTypeAheadButton: (() -> Void)?
    
    private func typeAheadButton() -> UIButton {
        let typeAheadButton = UIButton()
        typeAheadButton.setImage(UIImage(systemName: "arrow.up.left"), for: .normal)
        typeAheadButton.sizeToFit()
        typeAheadButton.addTarget(self, action: #selector(typeAheadButtonTap), for: .touchUpInside)
        return typeAheadButton
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = typeAheadButton()
        imageView?.image = UIImage(systemName: "magnifyingglass")
        tintColor = .lightGray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func typeAheadButtonTap(_ sender: UIButton) {
        didTapTypeAheadButton?()
    }
    
}

extension SearchSuggestionTableViewCell {
    
    func setup(with querySuggestion: QuerySuggestion) {
        guard let textLabel = textLabel else { return }
        textLabel.attributedText = querySuggestion
            .highlighted
            .flatMap(HighlightedString.init)
            .flatMap { NSAttributedString(highlightedString: $0,
                                          inverted: true,
                                          attributes: [.font: UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)])
            }
    }
    
}


public class QuerySuggestionsDemoViewController: UIViewController, TKCollectionViewDelegate, UISearchBarDelegate {
    
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        self.suggestionsViewController.searchText = searchText
        self.checkCache()
    }
    
    public func tagIsBeingAdded(name: String?) {
        
    }
    
    public func tagIsBeingRemoved(name: String?) {
        
    }
    
    
    let searchController: UISearchController
    let searcher: MultiSearcher
    
    let searchBoxInteractor : SearchBoxInteractor
//    let searchBoxConnector: SearchBoxConnector
    let textFieldController: TextFieldController
    
    let suggestionsHitsConnector: HitsConnector<QuerySuggestion> //
    let suggestionsViewController: SuggestionsTableViewController  //サジェスト一覧を表示するTableView
    
    //  let resultsHitsConnector: HitsConnector<Hit<Job>>
    //  let resultsViewController: StoreItemsTableViewController
    
    var addedWords : [String]? = []
    var tagCollection = TKCollectionView()
    
    var cache : [String:[QuerySuggestion]] = [:]
    var results : [QuerySuggestion] = []
    var timer : Timer?
    var searchText :String = ""

    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        searcher = .init(appID: "2JAYQSHTSY",
                         apiKey: "1b0e4f7a6529f190da4bddc29a4a7c25")
        
        
        let suggestionsSearcher = searcher.addHitsSearcher(indexName: "jobs_query_suggestions")
        suggestionsViewController = .init(style: .plain)
        suggestionsHitsConnector = HitsConnector(searcher: suggestionsSearcher,
                                                 interactor: .init(infiniteScrolling: .off),
                                                 controller: suggestionsViewController)
        
        //    let resultsSearcher = searcher.addHitsSearcher(indexName: "jobs")
        //    resultsViewController = .init(style: .plain)
        //    resultsHitsConnector = HitsConnector(searcher: resultsSearcher,
        //                                         interactor: .init(),
        //                                         controller: resultsViewController)
        
        searchController = .init(searchResultsController: suggestionsViewController)
        
        textFieldController = .init(searchBar: searchController.searchBar)
        
        searchBoxInteractor = .init()
        searchBoxInteractor.connectSearcher(searcher,searchTriggeringMode: .searchOnSubmit)
        searchBoxInteractor.connectController(textFieldController)
        
//        searchBoxConnector = .init(searcher: searcher,
//                                   controller: textFieldController)
        
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        searchController.searchBar.delegate  =  self
        self.setupTagView()
        self.searchController.searchBar.delegate = self
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func setupTagView(){
        tagCollection.receiver = tagCollection
        tagCollection.action = .removeTag
        tagCollection.customBackgroundColor = .blue
        
        tagCollection.customFont = .boldSystemFont(ofSize: 14)
        tagCollection.delegate = self
        tagCollection.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagCollection.view)
        
        NSLayoutConstraint.activate([
            tagCollection.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tagCollection.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 10),
            tagCollection.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: 10),
            tagCollection.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setup() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.showsSearchResultsController = true
        
        //    addChild(resultsViewController)
        //    resultsViewController.didMove(toParent: self)
        
//        searchBoxConnector.connectController(suggestionsViewController)
        
        searchBoxInteractor.onQuerySubmitted.subscribe(with: searchController) { (searchController, _) in
            if let suggestion = self.suggestionsViewController.selectedSuggestion{
                self.tagCollection.addNewTag(named:suggestion)
            }
            searchController.dismiss(animated: true, completion: .none)
        }
        
        //    searcher.search()
    }
    
    private func configureUI() {
        title = "Query Suggestions"
        view.backgroundColor = .white
        let tagContainerView  = UIView()
        
        
        let addedTagCountLabel = UILabel()
        addedTagCountLabel.text = ""
        //    let resultsView = resultsViewController.view!
        //    resultsView.translatesAutoresizingMaskIntoConstraints = false
        //    view.addSubview(resultsView)
        //    NSLayoutConstraint.activate([
        //      resultsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        //      resultsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        //      resultsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        //      resultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        //    ])
    }
    
    @objc func checkCache(){
        if let cachedSuggestion = self.suggestionsViewController.cache[searchText],!(cachedSuggestion.isEmpty){
            self.results = cachedSuggestion
            self.timer?.invalidate()
            if let index = self.results.firstIndex(where: {$0.query == self.searchText}){
                //検索結果に一致するタグがある場合
            }else{
                //ない場合、tableViewの一行目に検索したワードを入れる
                if !(self.searchText.isEmpty){
                    
                    self.results.insert(QuerySuggestion(query: self.searchText, highlighted: searchText, popularity: 0), at: 0)
                }
            }
            self.suggestionsViewController.tableView.reloadData()
            print(cachedSuggestion)
        }else{
            self.searchTimer()
        }
    }
    
    func searchTimer(){
        //テキスト入力後0.5秒間入力がない場合検索する
        //連続入力時に検索を行わないため
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchSuggestions), userInfo: nil, repeats: false)
    }
    
    @objc func searchSuggestions(){
        //検索
        suggestionsHitsConnector.searcher.setQuery(searchText)
        suggestionsHitsConnector.searcher.search()
        
    }
    
}


class StoreItemsTableViewController: UITableViewController, HitsController {
    
    var hitsSource: HitsInteractor<Hit<Job>>?
    
    var didSelect: ((Hit<Job>) -> Void)?
    
    let cellIdentifier = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hitsSource?.numberOfHits() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        guard let hit = hitsSource?.hit(atIndex: indexPath.row) else {
            return cell
        }
        cell.setup(with: hit)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let hit = hitsSource?.hit(atIndex: indexPath.row) {
            didSelect?(hit)
            
            
        }
    }
    
}


//import SDWebImage

class ProductTableViewCell: UITableViewCell {
    
    let itemImageView: UIImageView
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    let priceLabel: UILabel
    
    let mainStackView: UIStackView
    let labelsStackView: UIStackView
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        itemImageView = .init()
        titleLabel = .init()
        subtitleLabel = .init()
        mainStackView = .init()
        labelsStackView = .init()
        priceLabel = .init()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        //    itemImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.clipsToBounds = true
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.layer.masksToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.numberOfLines = 1
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 1
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .systemFont(ofSize: 14)
        
        labelsStackView.axis = .vertical
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.spacing = 3
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        labelsStackView.addArrangedSubview(priceLabel)
        labelsStackView.addArrangedSubview(UIView())
        
        mainStackView.axis = .horizontal
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.spacing = 20
        mainStackView.addArrangedSubview(itemImageView)
        mainStackView.addArrangedSubview(labelsStackView)
        
        contentView.addSubview(mainStackView)
        contentView.layoutMargins = .init(top: 5, left: 3, bottom: 5, right: 3)
        
        //    mainStackView.pin(to: contentView.layoutMarginsGuide)
        itemImageView.widthAnchor.constraint(equalTo: itemImageView.heightAnchor).isActive = true
    }
    
}

extension ProductTableViewCell {
    
    func setup(with productHit: Hit<Job>) {
        let product = productHit.object
        //    itemImageView.sd_setImage(with: product.images.first)
        
        if let highlightedName = productHit.hightlightedString(forKey: "title") {
            titleLabel.attributedText = NSAttributedString(highlightedString: highlightedName,
                                                           attributes: [
                                                            .foregroundColor: UIColor.blue
                                                           ])
        } else {
            titleLabel.text = product.title
        }
        
        if let highlightedDescription = productHit.hightlightedString(forKey: "context") {
            subtitleLabel.attributedText = NSAttributedString(highlightedString: highlightedDescription,
                                                              attributes: [
                                                                .foregroundColor: UIColor.blue
                                                              ])
        } else {
            subtitleLabel.text = product.context
        }
        
        if let price = product.context {
            priceLabel.text = "\(price) 円"
        }
        
    }
    
}
