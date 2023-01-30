//
//  JobDetailViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/12/25.
//

import UIKit

class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var contextView: UITextView!
    
    @IBOutlet weak var workingHoursTextView: UITextView!
    
    @IBOutlet weak var workingAreaTextView: UITextView!
    
    @IBOutlet weak var salaryTextView: UITextView!
    
    
    var job : Job?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "株式会社池島電気設備"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName:"JobDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "jobDetailCell")
        

        // Do any additional setup after loading the view.
    }
    
    
    
    
    override func viewDidLayoutSubviews() {

      scrollView.contentSize = contentView.frame.size
      scrollView.flashScrollIndicators()

    }
    
    
    func setupView(){
        guard let job = job else{return}
        self.companyName.text = job.companyName
        
    }
}

extension JobDetailViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "jobDetailCell", for: indexPath) as! JobDetailCollectionViewCell
        cell.cornerRadius = 10
        cell.imageView.image = UIImage(systemName: "building")
        cell.imageView.backgroundColor = .gray
//        cell.imageView.layer.borderColor = UIColor.black.cgColor
//        cell.imageView.layer.borderWidth = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let aspect :CGFloat = 16/9
        let width = height * aspect
        return CGSize(width: width , height: height)
    }
    
    
    
    
}
