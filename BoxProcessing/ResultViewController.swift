//
//  ResultViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import Foundation
import UIKit
import XLPagerTabStrip


class ResultViewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ResultViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "計算結果") // ButtonBarItemに表示される名前になります
    }
}
