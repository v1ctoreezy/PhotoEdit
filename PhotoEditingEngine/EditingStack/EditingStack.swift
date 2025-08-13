//
//  EditingStack.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.07.2025.
//

import Foundation
import Combine

protocol EditingStackItem: Identifiable {
    
}

protocol EditingStack<StackItem>: ObservableObject {
    associatedtype StackItem: EditingStackItem
    
    var reachedEnd: Bool { get }
        
    var stackObject: Stack<StackItem> { get }
    
    func pushItem(item: StackItem)
    func popItem() -> StackItem
    
    func moveBackwards() -> StackItem
    func moveForward() -> StackItem
}

final class PhotoEditingStackImpl<PhotoStackItem: EditingStackItem>: EditingStack {
    typealias StackItem = PhotoStackItem
    
    private var currentIndex: Int = -1
    
    var updateCurrentValue: CompletionBlock?
    
    var currentItemCurrentValueSubject = CurrentValueSubject<PhotoStackItem?, Never>(nil)
    
    var reachedEnd: Bool {
        currentIndex == stackObject.count - 1
    }
    
    var currentItem: PhotoStackItem? {
        currentIndex == -1 ? nil : stackObject[currentIndex]
    }
    
    var stackObject: Stack<PhotoStackItem> = Stack<PhotoStackItem>()
    
    func pushItem(item: PhotoStackItem) {
        if !reachedEnd {
            self.pushItemAtIndexInternal(item)
        } else {
            stackObject.push(item: item)
            self.currentIndex += 1
        }
        
        currentItemCurrentValueSubject.send(stackObject.last)
    }
    
    func popItem() -> PhotoStackItem {
        let value = stackObject.pop()
        self.currentIndex -= 1
        
        currentItemCurrentValueSubject.send(stackObject.last)
        return value
    }
    
    func moveBackwards() -> PhotoStackItem {
        self.currentIndex -= currentIndex - 1 >= 0 ? 1 : 0
        let value = stackObject[currentIndex]
        
        currentItemCurrentValueSubject.send(value)
        return value
    }
    
    func moveForward() -> PhotoStackItem {
        self.currentIndex += currentIndex + 1 <= stackObject.count - 1 ? 1 : 0
        let value = stackObject[currentIndex]
        
        currentItemCurrentValueSubject.send(value)
        return value
    }
    
    private func pushItemAtIndexInternal(_ item: PhotoStackItem) {
        stackObject.pushItemAt(index: currentIndex, item: item)
        self.currentIndex = stackObject.count - 1
    }
}
