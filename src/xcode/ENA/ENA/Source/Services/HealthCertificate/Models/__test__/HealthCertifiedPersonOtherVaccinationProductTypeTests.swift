//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertifiedPersonOtherVaccinationProductTypeTests: XCTestCase {

	// MARK: - unknown vaccination product

	func testGIVEN_OtherVaccinationProductType_WHEN_UpdateVaccinationState_THEN_isFullyVaccinated() throws {
		// GIVEN
		let expectedDate = Date()
		let expectedDateString = DateFormatter.packagesDayDateFormatter.string(from: expectedDate)
		let vaccinationProduct = "EU/1/20/1509"

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: vaccinationProduct,
									doseNumber: 1,
									totalSeriesOfDoses: 1,
									dateOfVaccination: expectedDateString
								)
							]
						),
						and: .fake(expirationTime: expectedDate)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		guard case let .fullyVaccinated(validInDays) = healthCertifiedPerson.vaccinationState else {
			XCTFail("Unexpected vaccination state")
			return
		}
		let vaccinationProductType = VaccinationProductType(value: vaccinationProduct)

		// THEN
		XCTAssertEqual(validInDays, 15)
		XCTAssertEqual(vaccinationProductType, .other)
	}

	func testGIVEN_OtherVaccinationProductType_WHEN_UpdateVaccinationState_THEN_isCompletelyProtected() throws {
		// GIVEN
		let expectedDate = Date()
		let vaccinationProduct = "EU/1/20/1509"

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: vaccinationProduct,
									doseNumber: 1,
									totalSeriesOfDoses: 1,
									dateOfVaccination: "2021-02-02"
								)
							]
						),
						and: .fake(expirationTime: expectedDate)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		guard case let .completelyProtected(validUntil) = healthCertifiedPerson.vaccinationState else {
			XCTFail("Unexpected vaccination state")
			return
		}
		let vaccinationProductType = VaccinationProductType(value: vaccinationProduct)

		// THEN
		XCTAssertTrue(equalWithOutMilliseconds(validUntil, expectedDate))
		XCTAssertEqual(vaccinationProductType, .other)
	}

	func testGIVEN_OtherVaccinationProductType_WHEN_UpdateVaccinationState_THEN_isPartiallyVaccinated() throws {
		// GIVEN
		let expectedDate = Date()
		let vaccinationProduct = "EU/1/20/1509"

		let expectedDateString = DateFormatter.packagesDayDateFormatter.string(from: expectedDate)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: vaccinationProduct,
									doseNumber: 1,
									totalSeriesOfDoses: 2,
									dateOfVaccination: expectedDateString
								)
							]
						),
						and: .fake(expirationTime: expectedDate)
					)
				)
			],
			isPreferredPerson: false
		)
		// WHEN
		let vaccinationProductType = VaccinationProductType(value: vaccinationProduct)

		// THEN
		XCTAssertEqual(healthCertifiedPerson.vaccinationState, .partiallyVaccinated)
		XCTAssertEqual(vaccinationProductType, .other)
	}

	// helper to avoid flaky tests with dates by differing some milliseconds
	func equalWithOutMilliseconds(_ date1: Date, _ date2: Date) -> Bool {
		let result = Calendar.current.compare(date1, to: date2, toGranularity: .second)
		return result == .orderedSame
	}

}