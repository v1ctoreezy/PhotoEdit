import SwiftUI

/// UI компонент для отображения истории операций редактирования
struct OperationHistoryView: View {
    
    @ObservedObject var operationManager: EditOperationManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.myBackground
                    .edgesIgnoringSafeArea(.all)
                
                if operationManager.operations.isEmpty {
                    emptyStateView
                } else {
                    operationListView
                }
            }
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !operationManager.operations.isEmpty {
                        Button(action: {
                            operationManager.clear()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет операций")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Примените фильтры, текст или регулировки,\nчтобы увидеть их здесь")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Operation List
    
    private var operationListView: some View {
        VStack(spacing: 0) {
            // Статистика
            statisticsHeaderView
                .padding(.vertical, 12)
                .background(Color.myBackground.opacity(0.95))
            
            // Список операций
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(operationManager.operations.enumerated()), id: \.element.id) { index, operation in
                        OperationRowView(
                            operation: operation,
                            index: index,
                            isActive: index <= operationManager.currentIndex,
                            onDelete: {
                                operationManager.removeOperation(id: operation.id)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
            // Контролы undo/redo
            undoRedoControlsView
                .padding(.vertical, 16)
                .background(Color.myBackground.opacity(0.95))
        }
    }
    
    // MARK: - Statistics Header
    
    private var statisticsHeaderView: some View {
        HStack(spacing: 20) {
            StatBadge(
                icon: "square.stack.3d.up.fill",
                value: "\(operationManager.operations.count)",
                label: "Всего"
            )
            
            StatBadge(
                icon: "checkmark.circle.fill",
                value: "\(operationManager.currentIndex + 1)",
                label: "Активных"
            )
            
            StatBadge(
                icon: "arrow.uturn.backward",
                value: operationManager.canUndo ? "Да" : "Нет",
                label: "Undo"
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Undo/Redo Controls
    
    private var undoRedoControlsView: some View {
        HStack(spacing: 20) {
            // Undo button
            Button(action: {
                withAnimation {
                    operationManager.undo()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Отменить")
                }
                .font(.headline)
                .foregroundColor(operationManager.canUndo ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    operationManager.canUndo ? Color.blue : Color.gray.opacity(0.3)
                )
                .cornerRadius(12)
            }
            .disabled(!operationManager.canUndo)
            
            // Redo button
            Button(action: {
                withAnimation {
                    operationManager.redo()
                }
            }) {
                HStack {
                    Text("Вернуть")
                    Image(systemName: "arrow.uturn.forward")
                }
                .font(.headline)
                .foregroundColor(operationManager.canRedo ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    operationManager.canRedo ? Color.blue : Color.gray.opacity(0.3)
                )
                .cornerRadius(12)
            }
            .disabled(!operationManager.canRedo)
        }
        .padding(.horizontal)
    }
}

// MARK: - Operation Row

private struct OperationRowView: View {
    let operation: AnyEditOperation
    let index: Int
    let isActive: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Index
            Text("\(index + 1)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(isActive ? Color.blue : Color.gray.opacity(0.5))
                .clipShape(Circle())
            
            // Icon
            Image(systemName: iconForType(operation.type))
                .font(.system(size: 20))
                .foregroundColor(colorForType(operation.type))
                .frame(width: 32)
            
            // Description
            VStack(alignment: .leading, spacing: 4) {
                Text(operation.description)
                    .font(.body)
                    .foregroundColor(isActive ? .white : .gray)
                
                Text(timeAgo(from: operation.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(width: 32, height: 32)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
    
    private func iconForType(_ type: EditOperationType) -> String {
        switch type {
        case .filter: return "camera.filters"
        case .text: return "textformat"
        case .sticker: return "face.smiling"
        case .drawing: return "pencil.tip.crop.circle"
        case .adjustment: return "slider.horizontal.3"
        case .blur: return "aqi.medium"
        case .crop: return "crop"
        case .rotate: return "rotate.right"
        case .flip: return "rectangle.portrait.arrowtriangle.2.inward"
        case .custom: return "wand.and.stars"
        }
    }
    
    private func colorForType(_ type: EditOperationType) -> Color {
        switch type {
        case .filter: return .purple
        case .text: return .blue
        case .sticker: return .yellow
        case .drawing: return .green
        case .adjustment: return .orange
        case .blur: return Color.blue.opacity(0.7)
        case .crop: return .pink
        case .rotate: return Color.purple.opacity(0.7)
        case .flip: return Color.blue.opacity(0.5)
        case .custom: return .white
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        
        if seconds < 60 {
            return "только что"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes) мин назад"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours) ч назад"
        } else {
            let days = Int(seconds / 86400)
            return "\(days) д назад"
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview

struct OperationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = EditOperationManager()
        
        // Добавляем тестовые операции
        manager.addOperation(FilterOperation(filterName: "Vintage", lutIdentifier: "vintage_01"))
        manager.addOperation(TextOperation(text: "Summer", position: .zero))
        manager.addOperation(AdjustmentOperation(adjustmentType: .brightness, value: 0.2))
        manager.addOperation(StickerOperation(stickerIdentifier: "heart", imageName: "heart"))
        
        return OperationHistoryView(operationManager: manager)
            .preferredColorScheme(.dark)
    }
}

