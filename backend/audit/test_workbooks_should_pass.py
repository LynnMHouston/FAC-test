from django.test import SimpleTestCase
import os
from functools import reduce
import re


from audit.intakelib import (
    extract_additional_eins,
    extract_additional_ueis,
    extract_audit_findings_text,
    extract_audit_findings,
    extract_corrective_action_plan,
    extract_federal_awards,
    extract_notes_to_sefa,
    extract_secondary_auditors,
)

from audit.validators import (
    validate_additional_eins_json,
    validate_additional_ueis_json,
    validate_corrective_action_plan_json,
    validate_federal_award_json,
    validate_findings_text_json,
    validate_findings_uniform_guidance_json,
    validate_notes_to_sefa_json,
    validate_secondary_auditors_json,
)


def map_file_to_extractor_validator(filename):
    file_mapping = {
        "additional-eins": (extract_additional_eins, validate_additional_eins_json),
        "additional-ueis": (extract_additional_ueis, validate_additional_ueis_json),
        "audit-findings-text-": (
            extract_audit_findings_text,
            validate_findings_text_json,
        ),
        "audit-findings-": (
            extract_audit_findings,
            validate_findings_uniform_guidance_json,
        ),
        "corrective-action-plan": (
            extract_corrective_action_plan,
            validate_corrective_action_plan_json,
        ),
        "federal-awards": (extract_federal_awards, validate_federal_award_json),
        "notes-to-sefa": (extract_notes_to_sefa, validate_notes_to_sefa_json),
        "secondary-auditors": (
            extract_secondary_auditors,
            validate_secondary_auditors_json,
        ),
    }
    for reg, tup in file_mapping.items():
        if re.search(reg, filename):
            return (tup[0], tup[1])
    return (None, None)


def process_workbook_set(workbook_set_path):
    """Process each workbook set in the given path."""
    for wb_path, _, wb_files in os.walk(workbook_set_path):
        for file in wb_files:
            if re.search("xlsx$", str(file)):
                full_path = os.path.join(wb_path, file)
                (extractor, validator) = map_file_to_extractor_validator(full_path)
                if extractor:
                    print(f"Extracting and validating {file}")
                    ir = extractor(full_path)
                    validator(ir)
                else:
                    print(f"No extractor found for [{file}]")


class PassingWorkbooks(SimpleTestCase):
    def test_passing_workbooks(self):
        workbook_sets = reduce(
            os.path.join, ["audit", "fixtures", "workbooks", "should_pass"]
        )
        for dirpath, dirnames, _ in os.walk(workbook_sets):
            for workbook_set in dirnames:
                print("Walking ", workbook_set)
                process_workbook_set(os.path.join(dirpath, workbook_set))

    # Can't run this when subclased from SimpleTestCase.
    # Can't write to the database `default`.
    # However, we have to write real data to test the API.
    # For now, running the E2E tests and checking that the data is in
    # the API will have to wait for another day.
    # def test_workbooks_end_to_end(self):
    #     run_end_to_end(os.getenv("CYPRESS_LOGIN_TEST_EMAIL_AUDITEE"),
    #                    "100010",
    #                    "22")
