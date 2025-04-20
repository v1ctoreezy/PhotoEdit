//
//  TabBarItemView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

//struct TabBarItemView: View {
//
//    let page: TabBarPage
//    @Binding var isPressed: Bool
//    @State private var scale: CGFloat = 1.0
//    var isSelected: Bool
//
//    init(page: TabBarPage, isActive: Binding<Bool>, isSelected: Bool) {
//        self.page = page
//        self._isPressed = isActive
//        self.isSelected = isSelected
//    }
//
//
//
//    var body: some View {
//        HStack(spacing: 10) {
//            Spacer()
//            page.pageImage()
//                .renderingMode(.template)
//                .foregroundColor(isSelected ? .appOrange500 : .appBWVariants300600)
//                .scaleEffect(scale)
//                .animation(.spring(response: 0.15, dampingFraction: 0.35, blendDuration: 0.35), value: scale)
//
//            Spacer()
//        }
//        .onChange(of: isPressed) { newValue in
//            if newValue {
//                withAnimation {
//                    scale = 0.9
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    withAnimation {
//                        scale = 1.1
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation {
//                            scale = 1.0
//                        }
//                    }
//                }
//            } else {
//                scale = 1.0
//            }
//        }
//        .onAppear {
//            print(page.rawValue)
//        }
//    }
//}

import Foundation
import UIKit
import SwiftUI

class TabBarItemView: UIView {

    var callback: ((TabBarPage) -> Void)?

    //MARK: - Content
    private var itemImage: UIImageView = UIImageView()
    //var itemLabel: UILabel!

    private lazy var amountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.backgroundColor = Color.appGreen100.uiColor()
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.alpha = 0
        self.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            view.heightAnchor.constraint(equalToConstant: 16)
        ])
        return view
    }()

    private lazy var moneyFormatter: NumberFormatter = {
        let moneyFormatter = NumberFormatter()
        moneyFormatter.groupingSeparator = " "
        moneyFormatter.numberStyle = .decimal
        moneyFormatter.locale = Locale.current
        moneyFormatter.minimumFractionDigits = 0
        moneyFormatter.maximumFractionDigits = 0
        moneyFormatter.currencySymbol = "P"
        return moneyFormatter
    }()

    private lazy var amountLabel: EFCountingLabel = {
        let view = EFCountingLabel()
        view.isUserInteractionEnabled = false
        view.textAlignment = .center
        view.numberOfLines = 1
        view.text = ""
        view.adjustsFontSizeToFitWidth = false
        view.minimumScaleFactor = 0.01
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.formatBlock = { [weak self] (value) in "1" }
        amountView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: amountView.topAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 6),
            view.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -6),
            view.bottomAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 0)
        ])
        return view
    }()

    private lazy var badge: UIView = {
        let messageView = UIView()
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.layer.cornerRadius = 7.5
        messageView.backgroundColor = Color.appGreen100.uiColor()
        messageView.clipsToBounds = true
        messageView.isUserInteractionEnabled = false
        self.addSubview(messageView)

        NSLayoutConstraint.activate([
            messageView.bottomAnchor.constraint(equalTo: itemImage.centerYAnchor, constant: 0),
            messageView.leadingAnchor.constraint(equalTo: itemImage.centerXAnchor, constant: 0),
            messageView.widthAnchor.constraint(equalToConstant: 15),
            messageView.heightAnchor.constraint(equalToConstant: 15)
        ])
        return messageView
    }()

    private lazy var badgeText: UILabel = {

        let messagesLabel = UILabel()
        messagesLabel.isUserInteractionEnabled = false
        messagesLabel.textAlignment = .center
        messagesLabel.numberOfLines = 0
        messagesLabel.text = ""
        messagesLabel.adjustsFontSizeToFitWidth = true
        messagesLabel.minimumScaleFactor = 0.01
        messagesLabel.textColor = .white
        messagesLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        messagesLabel.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(messagesLabel)

        NSLayoutConstraint.activate([
            messagesLabel.topAnchor.constraint(equalTo: badge.topAnchor, constant: 1.5),
            messagesLabel.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 1.5),
            messagesLabel.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -1.5),
            messagesLabel.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -1.5)
        ])
        return messagesLabel
    }()

    var tabType: TabBarPage = .photoEdit {
        didSet {
            itemImage.image = tabType.pageIcon()
        }
    }

    var amount: Double = 0 {
        didSet{
            if amount != oldValue {
                amountLabel.method = .easeInOut
                
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                    let transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    self.amountView.transform = transform
                },
                               completion: { (val) in
                    self.amountLabel.countFrom(CGFloat(oldValue), to: CGFloat(self.amount), withDuration: 0.8)
                    UIView.animate(withDuration: 0.3,
                                   delay: 0.6,
                                   options: .curveEaseOut,
                                   animations: {
                        let transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                        self.amountView.transform = transform
                    },
                                   completion: nil)
                })
            } else if amount == 0 {
                amountLabel.text = "1"
            }
            
            if isEmpty {
                amountView.alpha = 0
                amountLabel.alpha = 0
            } else {
                amountView.alpha = 1
                amountLabel.alpha = 1
            }
        }
    }
    
    var isEmpty = true {
        didSet {
            amountView.alpha = isEmpty ? 0 : 1
            amountLabel.alpha = isEmpty ? 0 : 1
        }
    }

    var isActive: Bool = false {
        didSet {
            let imgColor: UIColor = isActive ? Color.appGreen100.uiColor() : UIColor.black
            UIView.transition(with: itemImage,
                    duration: 0.1,
                    options: .transitionCrossDissolve,
                    animations: { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        self.itemImage.tintColor = imgColor
                        self.amountView.backgroundColor = imgColor
                    },
                    completion: nil)
        }
    }

    //MARK: - Init
    init(tabType: TabBarPage) {
        self.tabType = tabType
        super.init(frame: CGRect.zero)
        config()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config() {

        [itemImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        let constraints = [
            itemImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            itemImage.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        itemImage.image = tabType.pageIcon()

        addGesture()
    }

    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tap)
    }


    //MARK: - Actions

    @objc func tapped() {
        callback?(tabType)
    }

    func setCount(count: Int) {
        badge.isHidden = count == 0
        badgeText.text = String(count)
    }

}


public enum EFLabelCountingMethod: Int {
    case linear = 0
    case easeIn = 1
    case easeOut = 2
    case easeInOut = 3
}

//MARK: - UILabelCounter
let kUILabelCounterRate = Float(3.0)

public protocol UILabelCounter {
    func update(_ t: CGFloat) -> CGFloat
}

public class UILabelCounterLinear: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        return t
    }
}

public class UILabelCounterEaseIn: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        return CGFloat(powf(Float(t), kUILabelCounterRate))
    }
}

public class UILabelCounterEaseOut: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        return CGFloat(1.0 - powf(Float(1.0 - t), kUILabelCounterRate))
    }
}

public class UILabelCounterEaseInOut: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        let newt: CGFloat = 2 * t
        if newt < 1 {
            return CGFloat(0.5 * powf (Float(newt), kUILabelCounterRate))
        } else {
            return CGFloat(0.5 * (2.0 - powf(Float(2.0 - newt), kUILabelCounterRate)))
        }
    }
}

//MARK: - EFCountingLabel
open class EFCountingLabel: UILabel {

    public var format = "%f"
    public var method = EFLabelCountingMethod.linear
    public var animationDuration = TimeInterval(2)
    public var formatBlock: ((CGFloat) -> String)?
    public var attributedFormatBlock: ((CGFloat) -> NSAttributedString)?
    public var completionBlock: (() -> Void)?

    private var startingValue: CGFloat!
    private var destinationValue: CGFloat!
    private var progress: TimeInterval = 0
    private var lastUpdate: TimeInterval!
    private var totalTime: TimeInterval!
    private var easingRate: CGFloat!

    private var timer: CADisplayLink?
    private var counter: UILabelCounter = UILabelCounterLinear()

    public func countFrom(_ startValue: CGFloat, to endValue: CGFloat) {
        self.countFrom(startValue, to: endValue, withDuration: self.animationDuration)
    }

    public func countFrom(_ startValue: CGFloat, to endValue: CGFloat, withDuration duration: TimeInterval) {
        self.startingValue = startValue
        self.destinationValue = endValue

        // remove any (possible) old timers
        self.timer?.invalidate()
        self.timer = nil

        if duration == 0.0 {
            // No animation
            self.setTextValue(endValue)
            self.runCompletionBlock()
            return
        }

        self.easingRate = 3.0
        self.progress = 0
        self.totalTime = duration
        self.lastUpdate = Date.timeIntervalSinceReferenceDate

        switch self.method {
        case .linear:
            self.counter = UILabelCounterLinear()
            break
        case .easeIn:
            self.counter = UILabelCounterEaseIn()
            break
        case .easeOut:
            self.counter = UILabelCounterEaseOut()
            break
        case .easeInOut:
            self.counter = UILabelCounterEaseInOut()
            break
        }

        let timer = CADisplayLink(target: self, selector: #selector(EFCountingLabel.updateValue(_:)))
        if #available(iOS 10.0, *) {
            timer.preferredFramesPerSecond = 30
        } else {
            timer.frameInterval = 2
        }
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.tracking)
        self.timer = timer
    }

    public func countFromCurrentValueTo(_ endValue: CGFloat) {
        self.countFrom(self.currentValue(), to: endValue)
    }

    public func countFromCurrentValueTo(_ endValue: CGFloat, withDuration duration: TimeInterval) {
        self.countFrom(self.currentValue(), to: endValue, withDuration: duration)
    }

    public func countFromZeroTo(_ endValue: CGFloat) {
        self.countFrom(0, to: endValue)
    }

    public func countFromZeroTo(_ endValue: CGFloat, withDuration duration: TimeInterval) {
        self.countFrom(0, to: endValue, withDuration: duration)
    }

    public func currentValue() -> CGFloat {
        if self.progress == 0 {
            return 0
        } else if self.progress >= self.totalTime {
            return self.destinationValue
        }

        let percent = self.progress / self.totalTime
        let updateVal = self.counter.update(CGFloat(percent))

        return self.startingValue + updateVal * (self.destinationValue - self.startingValue)
    }

    @objc public func updateValue(_ timer: Timer) {
        // update progress
        let now = Date.timeIntervalSinceReferenceDate
        self.progress = self.progress + now - self.lastUpdate
        self.lastUpdate = now

        if self.progress >= self.totalTime {
            self.timer?.invalidate()
            self.timer = nil
            self.progress = self.totalTime
        }

        self.setTextValue(self.currentValue())

        if self.progress == self.totalTime {
            self.runCompletionBlock()
        }
    }

    private func setTextValue(_ value: CGFloat) {
        if let tryAttributedFormatBlock = self.attributedFormatBlock {
            self.attributedText = tryAttributedFormatBlock(value)
        } else if let tryFormatBlock = self.formatBlock {
            self.text = tryFormatBlock(value)
        } else {
            // check if counting with ints - cast to int
            if nil != self.format.range(of: "%(.*)d", options: String.CompareOptions.regularExpression, range: nil)
                       || nil != self.format.range(of: "%(.*)i") {
                self.text = String(format: self.format, Int(value))
            } else {
                self.text = String(format: self.format, value)
            }
        }
    }

    private func setFormat(_ format: String) {
        self.format = format
        self.setTextValue(self.currentValue())
    }

    private func runCompletionBlock() {
        if let tryCompletionBlock = self.completionBlock {
            tryCompletionBlock()

            self.completionBlock = nil
        }
    }
}
