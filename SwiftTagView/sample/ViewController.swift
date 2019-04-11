//
//  ViewController.swift
//  sample
//
//  Created by 洪 権 on 2019/03/29.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit
import SwiftTagView

class ViewController: UIViewController {
    var tags : [String] = ["Swift","Objective C","Ruby","PHP","Python","Java","JQuery","Java","Kotlin","Go","C#"]
    var tagView1: SwiftTagView!
    var tagView2: SwiftTagView!
    var tagView3: SwiftTagView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupView()
    }

    private func setupView() {
        let margin = CGFloat(20.0)

        let segmentYpoint = CGFloat(100.0)
        let segcon: UISegmentedControl = UISegmentedControl(items: ["Single","Multable","Editable"])
        segcon.center = CGPoint(x: self.view.frame.width/2, y: segmentYpoint)
        segcon.backgroundColor = .white
        segcon.tintColor = .blue
        segcon.selectedSegmentIndex = 0
        segcon.addTarget(self, action: #selector(self.segconChanged(_:)), for: .valueChanged)
        self.view.addSubview(segcon)

        let tagListYpoint = CGFloat(200.0)
        let tagList1Height = CGFloat(300.0)
        self.tagView1 = SwiftTagView(frame: CGRect(x: margin, y: tagListYpoint + margin, width:(self.view.frame.width - margin*2), height: tagList1Height))
        self.tagView1.setTagsWith(tags: tags, didSelected: {index in
            print("single selected \(index)")
            self.tagView1.isHidden = true
        })
        self.tagView1.backgroundColor = UIColor.yellow
        self.view.addSubview(self.tagView1)

        let tagList2Height = CGFloat(330.0)
        self.tagView2 = SwiftTagView(frame: CGRect(x: margin, y: tagListYpoint + margin, width:(self.view.frame.width - margin*2), height: tagList2Height))
        self.tagView2.backgroundColor = UIColor.lightGray
        self.tagView2.setTagsWith(tagType: .multable, tags: tags, title: "Multi-Selectable Tags", didSelected: {indexs in
            print("multi-selected \(indexs)")
            self.tagView2.isHidden = true
        })
        self.view.addSubview(self.tagView2)

        let tagList3Height = CGFloat(350.0)
        self.tagView3 = SwiftTagView(frame: CGRect(x: margin, y: tagListYpoint + margin, width:(self.view.frame.width - margin*2), height: tagList3Height))
        self.tagView3.backgroundColor = UIColor.blue
        self.tagView3.setTagsWith(tagType: .editable, tags: tags, title: "Editable Tags", didSelected: {indexs in
            print("edit selected \(indexs)")
            self.tagView3.isHidden = true
        })
        self.view.addSubview(self.tagView3)

        self.tagView1.isHidden = false
        self.tagView2.isHidden = true
        self.tagView3.isHidden = true
    }
}

extension ViewController {
    @objc func segconChanged(_ segcon: UISegmentedControl) {
        switch segcon.selectedSegmentIndex {
        case 0:
            self.tagView1.isHidden = false
            self.tagView2.isHidden = true
            self.tagView3.isHidden = true
        case 1:
            self.tagView1.isHidden = true
            self.tagView2.isHidden = false
            self.tagView3.isHidden = true
        case 2:
            self.tagView1.isHidden = true
            self.tagView2.isHidden = true
            self.tagView3.isHidden = false
        default:
            break
        }
    }
}
