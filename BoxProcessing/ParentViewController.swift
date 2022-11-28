//
//  ParentViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import XLPagerTabStrip // ライブラリをインポートする

// デフォルトで継承している UIViewController を ButtonBarPagerTabStripViewController に書き換える
class ParentViewController: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var settingButton: UIButton!
    // …
    override func viewDidLoad() {
           
           //バーの色
           settings.style.buttonBarBackgroundColor = .white
           //ボタンの色
           settings.style.buttonBarItemBackgroundColor = .white
           //セルの文字色
           settings.style.buttonBarItemTitleColor = .label
           settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 20)
           //セレクトバーの色
           settings.style.selectedBarBackgroundColor = .init(hex: "3C73E8")
           settings.style.buttonBarLeftContentInset = 15
           settings.style.buttonBarRightContentInset = 15
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
           settings.style.buttonBarItemsShouldFillAvailableWidth = false
           settings.style.buttonBarItemLeftRightMargin  = 15
           settings.style.selectedBarVerticalAlignment = .middle
           setupNavigaitonBar(color: .white)

           //選択されたtitleの色と大きさ変更
           changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
               guard changeCurrentIndex == true else { return }

               oldCell?.label.textColor = .lightGray
               newCell?.label.textColor = .label

               if animated {
                   UIView.animate(withDuration: 0.1, animations: { () -> Void in
                       newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                       oldCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                   })
               }
               else {
                   newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                   oldCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
               }
           }
           
           super.viewDidLoad()
           self.navigationController?.navigationBar.isHidden = true

        settingButton.addTarget(self, action: #selector(tappedSettingButton), for: .touchUpInside)
              // Do any additional setup after loading the view, typically from a nib.
          }
//       func setupNavigationTitle(){
//
//           let nameLabel = UILabel()
//           nameLabel.text = "カレンダー募集"
//           nameLabel.font = .boldSystemFont(ofSize: 24)
//           nameLabel.adjustsFontSizeToFitWidth = true
//           let titleItem = UIBarButtonItem(customView: nameLabel )
//
//           self.navigationItem.leftBarButtonItem = titleItem
//       }

    @objc func tappedSettingButton(){
        let sb = UIStoryboard(name: "PipeSettingView", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PipeSettingViewController") as! PipeSettingViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
          override func didReceiveMemoryWarning() {
              super.didReceiveMemoryWarning()
              // Dispose of any resources that can be recreated.
          }
          
          override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
              //管理されるViewControllerを返す処理
              let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InputViewController")
              let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController")
              let childViewControllers:[UIViewController] = [firstVC, secondVC ]
              return childViewControllers
          }
    
}
