//
//  TextLabel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 06.09.2025.
//

import UIKit

final class ResizableLabelView: UIView {

    private let label = UILabel()
    private var borderLayer: CAShapeLayer?
    var handles: [UIView] = []
    
    // Хэндлы для изменения размера
    private var topLeftHandle: UIView?
    private var topRightHandle: UIView?
    private var bottomLeftHandle: UIView?
    private var bottomRightHandle: UIView?
    private var topHandle: UIView?
    private var bottomHandle: UIView?
    private var leftHandle: UIView?
    private var rightHandle: UIView?

    private let handleSize: CGFloat = 20
    private let padding: CGFloat = 8
    private let minWidth: CGFloat = 60
    private let minHeight: CGFloat = 30
    
    // Флаг для отслеживания режима изменения размера
    private var isResizing = false
    private var resizeHandle: UIView?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = true // будем управлять фреймами вручную
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        addSubview(label)

        // Tap для показа/скрытия рамки и хэндлов
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSelection))
        addGestureRecognizer(tap)
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // label занимает контейнер с отступами
        label.frame = bounds.insetBy(dx: padding, dy: padding)

        // обновляем рамку
        if let border = borderLayer {
            border.path = UIBezierPath(rect: bounds).cgPath
        }

        // обновляем все хэндлы
        updateHandlesPosition()
    }
    
    private func updateHandlesPosition() {
        let bounds = self.bounds
        let halfHandle = handleSize / 2
        
        // Угловые хэндлы
        topLeftHandle?.frame = CGRect(x: -halfHandle, y: -halfHandle, width: handleSize, height: handleSize)
        topRightHandle?.frame = CGRect(x: bounds.width - halfHandle, y: -halfHandle, width: handleSize, height: handleSize)
        bottomLeftHandle?.frame = CGRect(x: -halfHandle, y: bounds.height - halfHandle, width: handleSize, height: handleSize)
        bottomRightHandle?.frame = CGRect(x: bounds.width - halfHandle, y: bounds.height - halfHandle, width: handleSize, height: handleSize)
        
        // Боковые хэндлы
        topHandle?.frame = CGRect(x: bounds.midX - halfHandle, y: -halfHandle, width: handleSize, height: handleSize)
        bottomHandle?.frame = CGRect(x: bounds.midX - halfHandle, y: bounds.height - halfHandle, width: handleSize, height: handleSize)
        leftHandle?.frame = CGRect(x: -halfHandle, y: bounds.midY - halfHandle, width: handleSize, height: handleSize)
        rightHandle?.frame = CGRect(x: bounds.width - halfHandle, y: bounds.midY - halfHandle, width: handleSize, height: handleSize)
    }

    // MARK: - Public
    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            // Автоматически подгоняем размер под текст
            fitSizeToText()
        }
    }
    
    var font: UIFont? {
        get { label.font }
        set {
            label.font = newValue
            fitSizeToText()
        }
    }

    // Подгоняем размер контейнера под текст
    private func fitSizeToText() {
        guard let text = label.text, !text.isEmpty else {
            // Если текста нет, устанавливаем минимальный размер
            var f = frame
            f.size = CGSize(width: minWidth, height: minHeight)
            frame = f
            setNeedsLayout()
            return
        }
        
        // Сначала определяем оптимальную ширину для текста
        let maxWidth: CGFloat = 300 // максимальная ширина для автоматического размера
        let textSize = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        
        var newFrame = frame
        newFrame.size.width = max(textSize.width + padding * 2, minWidth)
        newFrame.size.height = max(textSize.height + padding * 2, minHeight)
        
        frame = newFrame
        setNeedsLayout()
    }
    
    // Подгоняем высоту контейнера под текст при текущей ширине
    private func fitHeightToTextForCurrentWidth() {
        let contentWidth = max(bounds.width - padding*2, 1)
        let needed = label.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        var f = frame
        f.size.height = max(needed.height + padding*2, minHeight)
        frame = f
        setNeedsLayout()
    }

    // MARK: - Selection UI
    @objc private func toggleSelection() {
        if borderLayer == nil {
            showSelection()
        } else {
            hideSelection()
        }
    }

    func showSelection() {
        // рамка
        let border = CAShapeLayer()
        border.strokeColor = UIColor.systemBlue.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = 2
        border.lineDashPattern = [4, 2]
        border.path = UIBezierPath(rect: bounds).cgPath
        layer.addSublayer(border)
        self.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        borderLayer = border

        // Создаем все хэндлы
        createHandles()
        setNeedsLayout()
    }

    func hideSelection() {
        self.backgroundColor = .clear
        borderLayer?.removeFromSuperlayer()
        borderLayer = nil
        removeAllHandles()
    }
    
    private func createHandles() {
        // Угловые хэндлы
        topLeftHandle = createHandle(for: .topLeft)
        topRightHandle = createHandle(for: .topRight)
        bottomLeftHandle = createHandle(for: .bottomLeft)
        bottomRightHandle = createHandle(for: .bottomRight)
        
        // Боковые хэндлы
        topHandle = createHandle(for: .top)
        bottomHandle = createHandle(for: .bottom)
        leftHandle = createHandle(for: .left)
        rightHandle = createHandle(for: .right)
        
        // Добавляем в массив для удобства
        handles = [topLeftHandle, topRightHandle, bottomLeftHandle, bottomRightHandle,
                  topHandle, bottomHandle, leftHandle, rightHandle].compactMap { $0 }
    }
    
    private func removeAllHandles() {
        handles.forEach { $0.removeFromSuperview() }
        handles.removeAll()
        topLeftHandle = nil
        topRightHandle = nil
        bottomLeftHandle = nil
        bottomRightHandle = nil
        topHandle = nil
        bottomHandle = nil
        leftHandle = nil
        rightHandle = nil
    }

    // MARK: - Handle Types
    private enum HandleType: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
    }
    
    private func createHandle(for type: HandleType) -> UIView {
        let handle = UIView(frame: CGRect(x: 0, y: 0, width: handleSize, height: handleSize))
        handle.backgroundColor = .white
        handle.layer.cornerRadius = 3
        handle.layer.borderColor = UIColor.systemBlue.cgColor
        handle.layer.borderWidth = 2
        handle.isUserInteractionEnabled = true
        
        // Добавляем жест для изменения размера
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleResizePan(_:)))
        handle.addGestureRecognizer(panGesture)
        
        // Сохраняем тип хэндла в теге
        handle.tag = type.hashValue
        
        addSubview(handle)
        return handle
    }
    
    private func makeHandle() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: handleSize, height: handleSize))
        v.backgroundColor = .white
        v.layer.cornerRadius = 3
        v.layer.borderColor = UIColor.systemBlue.cgColor
        v.layer.borderWidth = 1
        v.isUserInteractionEnabled = true
        return v
    }

    // MARK: - Resizing
    @objc private func handleResizePan(_ gesture: UIPanGestureRecognizer) {
        guard let handle = gesture.view else { return }
        guard let superview = superview else { return }
        
        let translation = gesture.translation(in: superview)
        gesture.setTranslation(.zero, in: superview)
        
        // Определяем тип хэндла по тегу
        let handleType = HandleType.allCases.first { $0.hashValue == handle.tag } ?? .bottomRight
        
        var newFrame = frame
        
        switch gesture.state {
        case .began:
            isResizing = true
            resizeHandle = handle
            
        case .changed:
            // Применяем изменения в зависимости от типа хэндла
            applyResize(to: &newFrame, handleType: handleType, translation: translation)
            
            // Ограничиваем минимальные размеры
            newFrame.size.width = max(newFrame.size.width, minWidth)
            newFrame.size.height = max(newFrame.size.height, minHeight)
            
            // Пересчитываем высоту под текст при изменении ширины
            if handleType == .left || handleType == .right || 
               handleType == .topLeft || handleType == .topRight || 
               handleType == .bottomLeft || handleType == .bottomRight {
                fitHeightToTextForCurrentWidth()
            }
            
            frame = newFrame
            setNeedsLayout()
            
        case .ended, .cancelled:
            isResizing = false
            resizeHandle = nil
            
        default:
            break
        }
    }
    
    private func applyResize(to frame: inout CGRect, handleType: HandleType, translation: CGPoint) {
        switch handleType {
        case .topLeft:
//            frame.origin.x += translation.x
//            frame.origin.y += translation.y
            frame.size.width -= translation.x
            frame.size.height -= translation.y
            
        case .topRight:
//            frame.origin.y += translation.y
            frame.size.width += translation.x
            frame.size.height -= translation.y
            
        case .bottomLeft:
//            frame.origin.x += translation.x
            frame.size.width -= translation.x
            frame.size.height += translation.y
            
        case .bottomRight:
            frame.size.width += translation.x
            frame.size.height += translation.y
            
        case .top:
//            frame.origin.y += translation.y
            frame.size.height -= translation.y
            
        case .bottom:
            frame.size.height += translation.y
            
        case .left:
//            frame.origin.x += translation.x
            frame.size.width -= translation.x
            
        case .right:
            frame.size.width += translation.x
        }
    }
}

