import UIKit
import Foundation


func substring(_ string: String, with nsrange: NSRange) -> Substring? {
    guard let range = Range(nsrange, in: string) else { return nil }
    return string[range]
}


var dosageString = "3 DOSAGE FORMS AND STRENGTHS MYRBETRIQ® extended-release tablets are supplied in two different strengths as described below: • 25 mg oval, brown, film coated tablet, debossed with the (Astellas logo) and “325” • 50 mg oval, yellow, film coated tablet, debossed with the (Astellas logo) and “355” Extended-release tablets: 25 mg and 50 mg (3). Astellas logo Astellas logo"

let warningsString = "5 WARNINGS AND PRECAUTIONS • Increases in Blood Pressure: MYRBETRIQ® can increase blood pressure. Periodic blood pressure determinations are recommended, especially in hypertensive patients. MYRBETRIQ® is not recommended for use in severe uncontrolled hypertensive patients (5.1). • Urinary Retention in Patients With Bladder Outlet Obstruction and in Patients Taking Antimuscarinic Drugs for Overactive Bladder: Administer with caution in these patients because of risk of urinary retention (5.2). • Angioedema: Angioedema of the face, lips, tongue and/or larynx has been reported with MYRBETRIQ® (5.3, 6.2). • Patients Taking Drugs Metabolized by CYP2D6: MYRBETRIQ® is a moderate inhibitor of CYP2D6. Appropriate monitoring is recommended and dose adjustment may be necessary for narrow therapeutic index CYP2D6 substrates (5.4, 7.1, 12.3). 5.1 Increases in Blood Pressure MYRBETRIQ® can increase blood pressure. Periodic blood pressure determinations are recommended, especially in hypertensive patients. MYRBETRIQ® is not recommended for use in patients with severe uncontrolled hypertension (defined as systolic blood pressure greater than or equal to 180 mm Hg and/or diastolic blood pressure greater than or equal to 110 mm Hg) [see Clinical Pharmacology (12.2)]. In two, randomized, placebo-controlled, healthy volunteer studies, MYRBETRIQ® was associated with dose-related increases in supine blood pressure. In these studies, at the maximum recommended dose of 50 mg, the mean maximum increase in systolic/diastolic blood pressure was approximately 3.5/1.5 mm Hg greater than placebo. In contrast, in OAB patients in clinical trials, the mean increase in systolic and diastolic blood pressure at the maximum recommended dose of 50 mg was approximately 0.5 - 1 mm Hg greater than placebo. Worsening of pre-existing hypertension was reported infrequently in MYRBETRIQ® patients. 5.2 Urinary Retention in Patients with Bladder Outlet Obstruction and in Patients Taking Antimuscarinic Medications for OAB Urinary retention in patients with bladder outlet obstruction (BOO) and in patients taking antimuscarinic medications for the treatment of OAB has been reported in postmarketing experience in patients taking mirabegron. A controlled clinical safety study in patients with BOO did not demonstrate increased urinary retention in MYRBETRIQ® patients; however, MYRBETRIQ® should be administered with caution to patients with clinically significant BOO. MYRBETRIQ® should also be administered with caution to patients taking antimuscarinic medications for the treatment of OAB [see Clinical Pharmacology (12.2)]. 5.3 Angioedema Angioedema of the face, lips, tongue, and/or larynx has been reported with MYRBETRIQ®. In some cases angioedema occurred after the first dose. Cases of angioedema have been reported to occur hours after the first dose or after multiple doses. Angioedema associated with upper airway swelling may be life threatening. If involvement of the tongue, hypopharynx, or larynx occurs, promptly discontinue MYRBETRIQ® and initiate appropriate therapy and/or measures necessary to ensure a patent airway [see Adverse Reactions (6.2)]. 5.4 Patients Taking Drugs Metabolized by CYP2D6 Since mirabegron is a moderate CYP2D6 inhibitor, the systemic exposure to CYP2D6 substrates such as metoprolol and desipramine is increased when co-administered with mirabegron. Therefore, appropriate monitoring and dose adjustment may be necessary, especially with narrow therapeutic index drugs metabolized by CYP2D6, such as thioridazine, flecainide, and propafenone [see Drug Interactions (7.1) and Clinical Pharmacology (12.3)]."

func parseDosages(_ dosageString: String) -> [Int] {
    let pattern = "(\\d+) mg"
    let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    let matches = regex.matches(in: dosageString, range: NSMakeRange(0, dosageString.utf16.count))
    var dosages = Set<Int>()
    for match in matches {
        let range = match.range(at: 1)
        let dosage = Int(String(substring(dosageString, with: range)!))!
        dosages.insert(dosage)
    }
    return Array(dosages).sorted()
}

private func parseInteractions(_ interactions: String) -> String {
    var newInteractions = interactions
    newInteractions = interactions.replacingOccurrences(of: "7 DRUG INTERACTIONS ", with: "")
    newInteractions = newInteractions.replacingOccurrences(of: "\\[.*?\\]", with: "")
    return newInteractions
}

func parseWarning(_ warnings: String) -> String {
    var warningsClean = warnings.replacingOccurrences(of: "5 WARNINGS AND PRECAUTIONS • ", with: "")
    warningsClean = warningsClean.replacingOccurrences(of: "• |\\[.*?\\]|\\(.*?\\)", with: "", options: .regularExpression)
    warningsClean = warningsClean.replacingOccurrences(of: "  .", with: ".", options: .regularExpression)
    //warningsClean = warningsClean.replacingOccurrences(of: "\\d\\.\\d", with: "", options: .regularExpression)
    return warningsClean
}


