//
//  SwiftTagView.swift
//
//  Created by enix on 2019/03/28.
//  Copyright © 2019 enixsoft. All rights reserved.
//

import UIKit

public enum SwiftTagType : Int {
    case single = 0
    case multable = 1
    case editable = 2 // have a issue
}
public enum SwiftTagViewType : Int {
    case fill = 0
    case border = 1
}
let kTagViewHeight : CGFloat = 30.0   // Tag height
let kBorderColor : UIColor = UIColor.lightGray

public protocol SwiftTagViewDelegate: class {
    func didSelected(_ tagView: SwiftTagView, _ didSelected: ((_ selctedIndexes : [Int])->())?) -> Void
    func onClickDone(_ tagView: SwiftTagView, _ didSelected: ((_ selctedIndexes : [Int])->())?) -> Void
    func onClickCancel(_ tagView: SwiftTagView) -> Void
}

public class SwiftTagView: UIView {
    private let kMargin : CGFloat = 12.0
    private let kPadding : CGFloat = 5.0
    private let kHeaderHeight : CGFloat = 44.0
    private let kResultButtonHeight : CGFloat = 44.0

    public weak var delegate: SwiftTagViewDelegate?

    // Private Variables
    private var titleLabel : UILabel!
    private var scrollView : UIScrollView!
    private var doneButton : UIButton!
    private var cancelButton : UIButton!

    // UI Setting
    private var tagType : SwiftTagType = .single
    private var tagViewType : SwiftTagViewType = .fill
    var tagTextColor : UIColor = UIColor.lightGray
    var tagMainColor : UIColor = UIColor.orange
    var tagCornerRadius : CGFloat = 10.0

    var titleColor : UIColor = UIColor.darkGray
    var titleFont : UIFont = UIFont.systemFont(ofSize: 20.0)

    var doneButtonTitleColor : UIColor = UIColor.white
    var doneButtonBackgroundColor : UIColor = UIColor.orange
    var doneButtonTitle : String = "Done"
    var cancelButtonTitle : String = "Cancel"
    var doneButtonCornerRadius : CGFloat = 8.0

    private var maximumSelect : Int?
    private var minimumSelect : Int?
    private var arraySwiftTags : [UIButton] = []

    private var selectedIndexes : [Int] = []
    private var didSelected : ((_ selctedIndexes : [Int])->())?

    private var isOnDialog = false

    // MARK: Life Cycle
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setupUI(_ type: SwiftTagType = .single, _ title: String?) {
        self.tagType = type

        var tmpHeight = kTagViewHeight + kPadding*2 + kResultButtonHeight + kMargin + kPadding
        tmpHeight += (title != nil && title!.count > 0) ? (kHeaderHeight + kMargin + kPadding) : 0
        tmpHeight += (type == .multable) ? (kResultButtonHeight + kPadding) : 0

        if (self.frame.size.height < tmpHeight) {
            self.frame.size.height = tmpHeight
        }
        self.addTitleLabel(title)
        self.addCancelButton()
        self.addDoneButton()
        self.addScrollView()
    }

    // View Configure....
    private func addTitleLabel(_ title : String?) {
        self.titleLabel = UILabel(frame: .zero)
        self.titleLabel.text = title
        self.titleLabel.textColor = titleColor
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.font = titleFont
        self.titleLabel.backgroundColor = UIColor.white
        self.addSubview(self.titleLabel)
    }

    private func addCancelButton() {
        self.cancelButton = UIButton(frame:.zero)
        self.cancelButton.setTitle(self.cancelButtonTitle, for: .normal)
        self.cancelButton.setTitleColor(self.doneButtonTitleColor, for: .normal)
        self.cancelButton.setBackgroundImage(self.doneButtonBackgroundColor.toImage(), for: .normal)

        self.cancelButton.layer.cornerRadius = self.doneButtonCornerRadius
        self.cancelButton.addTarget(self, action: #selector(handleCancel(_ :)), for: .touchUpInside)
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.backgroundColor = UIColor.cyan
        self.addSubview(self.cancelButton)
    }

    private func addDoneButton() {
        self.doneButton = UIButton(frame: .zero)

        self.doneButton.setTitle(self.doneButtonTitle, for: .normal)
        self.doneButton.setTitleColor(self.doneButtonTitleColor, for: .normal)
        self.doneButton.setBackgroundImage(self.doneButtonBackgroundColor.toImage(), for: .normal)
        self.doneButton.layer.cornerRadius = self.doneButtonCornerRadius
        self.doneButton.layer.masksToBounds = true
        self.doneButton.addTarget(self, action: #selector(handleDone(_ :)), for: .touchUpInside)
        if self.minimumSelect != nil && self.minimumSelect! > 0 {
            self.doneButton.isEnabled = false
        }
        self.doneButton.backgroundColor = UIColor.blue
        self.addSubview(self.doneButton)
    }

    private func addScrollView() {
        self.scrollView = UIScrollView(frame:.zero)
        self.scrollView.isScrollEnabled = true
        self.scrollView.backgroundColor = UIColor.clear
        self.addSubview(self.scrollView)
    }

    private func configureTags(_ tags: [String]) {
        self.arraySwiftTags = []
        for (index,title) in tags.enumerated() {
            let tag : UIButton = getButton(index:index, title:title)

            tag.sizeToFit()
            tag.backgroundColor = UIColor.red
            self.arraySwiftTags.append(tag)
        }
        self.addAllButtons()
    }

    private func removeAllButtons() {
        for btn in self.scrollView.subviews{
            if btn is UIButton {
                btn.removeFromSuperview()
            }
        }
    }

    private func addAllButtons() {
        var xPosition = CGFloat(kMargin)
        var yPosition = CGFloat(kMargin)

        for (index,tag) in self.arraySwiftTags.enumerated() {
            let width = tag.frame.size.width + 10
            let nextBtnWidth = (index >= self.arraySwiftTags.count - 1) ? 0 : self.arraySwiftTags[index+1].frame.size.width
            tag.frame = CGRect(x: xPosition, y: yPosition, width: width, height: kTagViewHeight)

            xPosition = xPosition + width + nextBtnWidth + kPadding*2 > (self.frame.width - kMargin) ? kMargin : xPosition + width + kPadding
            yPosition = xPosition > kMargin ? yPosition : yPosition + kTagViewHeight + kPadding

            self.scrollView.addSubview(tag)
        }
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: yPosition + kTagViewHeight)
    }

    private func getButton(index: Int, title: String) -> UIButton {
        let btn : UIButton = UIButton(type: .custom)
        btn.layer.cornerRadius = tagCornerRadius
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = kBorderColor.cgColor
        btn.setTitle(title, for: .normal)
        btn.setImage(getTagImage(size:btn.frame.size, isSelected:btn.isSelected), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: btn.frame.width - (btn.imageView?.frame.width)!)

        btn.tag = index
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(self.handleSelected(_:)), for: .touchUpInside)
        if self.tagType == .editable {
            let lpGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
            lpGesture.minimumPressDuration = 0.5
            btn.addGestureRecognizer(lpGesture)
        }
        btn.setTitleColor(tagTextColor, for: .normal)

        switch self.tagViewType {
        case .fill:
            btn.setTitleColor(UIColor.white, for: .selected)
            btn.setBackgroundImage(tagMainColor.toImage(), for: .selected)
        case .border:
            btn.setTitleColor(tagMainColor, for: .selected)
            btn.setBackgroundImage(UIColor.white.toImage(), for: .normal)
        }
        return btn
    }

    private func getTagImage(size:CGSize, isSelected: Bool) -> UIImage?{
        class dummyClass {}
        let bundle = Bundle(for: type(of: dummyClass()))
        let named = isSelected ? "Tag2" : "Tag1"
        let image = UIImage(named: named, in: bundle, compatibleWith: nil)
        if size.height > 0 {
            return image?.resize(width:size.height - 6, height:size.height - 6)
        }
        return image?.resize(width:20, height:20)
    }

    // MARK: Handle Action
    @objc private func handleDone(_ btn : UIButton) {
        if self.didSelected != nil {
            self.didSelected!(self.selectedIndexes)
        }
        delegate?.onClickDone(self, self.didSelected)
    }

    @objc private func handleCancel(_ btn : UIButton) {
        if self.didSelected != nil {
            self.didSelected!([])
        }
        delegate?.onClickCancel(self)
    }

    @objc private func handleSelected(_ btn : UIButton) {
        switch self.tagType {
        case .single:
            self.unselectAll()
            btn.isSelected = true
            btn.layer.borderColor = (btn.isSelected) ? self.tagMainColor.cgColor : kBorderColor.cgColor

            self.updateSelectedIndexes()
            if self.didSelected != nil {
                self.didSelected!([btn.tag])
            }
            delegate?.didSelected(self, self.didSelected)
        case .multable:
            if self.maximumSelect != nil && self.maximumSelect! <= self.selectedIndexes.count && btn.isSelected == false {
                return
            }
            btn.isSelected = !btn.isSelected
            btn.setImage(getTagImage(size:btn.frame.size, isSelected:btn.isSelected), for: .normal)

            self.updateSelectedIndexes()
            if self.minimumSelect != nil {
                if self.selectedIndexes.count >= self.minimumSelect! {
                    self.doneButton.isEnabled = true
                } else {
                    self.doneButton.isEnabled = false
                }
            }
        case .editable:
            break
        }
    }

    @objc private func handleLongPress(_ sender : UIGestureRecognizer) {
        if self.isOnDialog {
            return
        }
        guard let index = sender.view?.tag else {
            return
        }
        if index < 0 || index > (self.arraySwiftTags.count - 1) {
            return
        }
        guard sender.view is UIButton else {
            print("is not Tag")
            return
        }
        let tag: UIButton = sender.view as! UIButton
        guard let tagName = tag.title(for: .normal) else {
            return
        }

        if (sender.state == .began) {
            self.isOnDialog = true
        }
        let alert = UIAlertController(title: "Tag \(tagName)", message: "Delete this Tag OK?", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete", style: .default, handler: {(action : UIAlertAction) -> Void in
            print("delete tag index \(index)")
            self.deleteSelectedTag(tag:tag)
            self.isOnDialog = false
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action : UIAlertAction) -> Void in
            self.isOnDialog = false
        })
        alert.addAction(delete)
        alert.addAction(cancel)

        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while ((topVC?.presentedViewController) != nil)  {
            topVC = topVC?.presentedViewController
        }
        topVC?.present(alert, animated: true, completion: nil)
    }

    override public func layoutSubviews() {
        let titleLabelFrame = CGRect(x: kMargin,
               y: kMargin,
               width: self.frame.size.width - kMargin*2,
               height: kHeaderHeight)

        self.titleLabel.frame = (self.titleLabel.text != nil ) ? titleLabelFrame : CGRect.zero
        self.cancelButton.frame = CGRect(x: kMargin,
                                         y: self.bounds.origin.y + self.frame.height - (kResultButtonHeight + kMargin),
                                         width: self.frame.width - kMargin*2,
                                         height: kResultButtonHeight)
        let doneButtonFrame = CGRect(x: kMargin,
               y: self.cancelButton.frame.origin.y - (kResultButtonHeight + kPadding),
               width: self.frame.width - kMargin*2,
               height: kResultButtonHeight)
        self.doneButton.frame = (self.tagType == .multable) ? doneButtonFrame : CGRect.zero

        var tmpHeight = kResultButtonHeight + kMargin + kPadding
        tmpHeight += (self.titleLabel.frame.size.height > 0) ? (kHeaderHeight + kMargin + kPadding) : 0
        tmpHeight += (self.doneButton.frame.size.height > 0) ? (kResultButtonHeight + kPadding) : 0

        let scrollHeight = self.frame.size.height - tmpHeight

        self.scrollView.frame = CGRect(x: 0,
                                       y: self.titleLabel.frame.origin.y + self.titleLabel.frame.height + kPadding,
                                       width: self.frame.width,
                                       height: scrollHeight)
        super.layoutSubviews()
    }

    private func unselectAll() {
        self.selectedIndexes = []
        for tag in self.arraySwiftTags {
            tag.isSelected = false
        }
    }

    private func selectAll() {
        self.selectedIndexes = []
        for tag in self.arraySwiftTags {
            tag.isSelected = true
            self.selectedIndexes.append(tag.tag)
        }
    }

    private func updateSelectedIndexes() {
        self.selectedIndexes = []
        for tag in self.arraySwiftTags {
            if tag.isSelected == true {
                self.selectedIndexes.append(tag.tag)
            }
        }
    }

    private func deleteSelectedTag(tag: UIButton) {
        self.arraySwiftTags.removeAll { $0 == tag }
        self.removeAllButtons()
        self.addAllButtons()
    }

    /// init with TagView
    public func setTagsWith(tagType: SwiftTagType = .single, tags: [String], title: String? = nil, maximumSelect: Int? = nil, minimumSelect: Int? = nil, didSelected : (([Int])->())?) {
        if maximumSelect != nil {
            self.maximumSelect = (maximumSelect! > tags.count) ? tags.count : maximumSelect!
        }
        if minimumSelect != nil {
            self.minimumSelect = minimumSelect!
        }
        self.didSelected = didSelected
        self.setupUI(tagType, title)
        self.configureTags(tags)
    }
}
