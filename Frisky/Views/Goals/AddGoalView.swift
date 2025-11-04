import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var goalName: String = ""
    @State private var selectedType: GoalManager.GoalType = .steps
    @State private var targetValue: String = ""
    @State private var selectedPeriod: GoalManager.TimePeriod = .day
    
    var body: some View {
        NavigationView {
            Form {
                
                Section("Goal Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach([GoalManager.GoalType.steps, .sleep, .exercise, .activeTime], id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                
                Section("Goal Details") {
                    TextField("Goal Name", text: $goalName)
                        .onAppear {
                            updateDefaultName()
                        }
                    
                    HStack {
                        TextField("Target", text: $targetValue)
                            .keyboardType(.decimalPad)
                        
                        Text(selectedType.unit)
                            .foregroundColor(.gray)
                    }
                }
                
               
                Section("Time Period") {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach([GoalManager.TimePeriod.day, .week, .month], id: \.self) { period in
                            Text("\(period.emoji) \(period.rawValue)")
                                .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
              
                Section("Preview") {
                    if let target = Double(targetValue), target > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Goal:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(goalName)")
                                .font(.headline)
                            
                            Text("\(formatNumber(target)) \(selectedType.unit) per \(selectedPeriod.rawValue.lowercased())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Enter a target value to see preview")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isValidGoal)
                }
            }
            .onChange(of: selectedType) { _, _ in
                updateDefaultName()
                updateDefaultTarget()
            }
            .onChange(of: selectedPeriod) { _, _ in
                updateDefaultName()
            }
        }
    }
    
    var isValidGoal: Bool {
        !goalName.isEmpty &&
        !targetValue.isEmpty &&
        Double(targetValue) ?? 0 > 0
    }
    

    func saveGoal() {
        guard let target = Double(targetValue), target > 0 else { return }
        
        let newGoal = HealthGoal(
            goalName: goalName,
            habitType: selectedType.rawValue,
            trackableGoal: target,
            period: selectedPeriod.rawValue
        )
        
        modelContext.insert(newGoal)
        
        do {
            try modelContext.save()
            print(" Saved new goal: \(goalName)")
            dismiss()
        } catch {
            print(" Error saving goal: \(error)")
        }
    }
    
 
    func updateDefaultName() {
        let periodName = selectedPeriod == .day ? "Daily" : selectedPeriod == .week ? "Weekly" : "Monthly"
        goalName = "\(periodName) \(selectedType.rawValue)"
    }
    
    func updateDefaultTarget() {
        switch selectedType {
        case .steps:
            targetValue = selectedPeriod == .day ? "10000" : selectedPeriod == .week ? "70000" : "300000"
        case .sleep:
            targetValue = selectedPeriod == .day ? "8" : selectedPeriod == .week ? "56" : "240"
        case .exercise:
            targetValue = selectedPeriod == .day ? "30" : selectedPeriod == .week ? "210" : "900"
        case .activeTime:
            targetValue = selectedPeriod == .day ? "60" : selectedPeriod == .week ? "420" : "1800"
        }
    }
    
    func formatNumber(_ value: Double) -> String {
        GoalManager.formatNumber(value, type: selectedType)
    }
}

#Preview {
    AddGoalView()
        .modelContainer(for: [HealthGoal.self])
}
