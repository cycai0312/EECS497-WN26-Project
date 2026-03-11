import Foundation
import SwiftData

protocol MedicationRepositoryType {
    func logDose(for medication: Medication, status: DoseStatus, at timestamp: Date) throws
    func deleteMedication(_ medication: Medication) throws
    func save() throws
}

@MainActor
final class LocalMedicationRepository: MedicationRepositoryType {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func logDose(for medication: Medication, status: DoseStatus, at timestamp: Date = Date()) throws {
        let log = DoseLog(
            medicationID: medication.id,
            medicationNameSnapshot: medication.name,
            timestamp: timestamp,
            status: status
        )
        modelContext.insert(log)
        try modelContext.save()
    }

    func deleteMedication(_ medication: Medication) throws {
        modelContext.delete(medication)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }
}
