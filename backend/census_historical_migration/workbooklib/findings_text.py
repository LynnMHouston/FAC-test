from ..workbooklib.excel_creation_utils import (
    map_simple_columns,
    generate_dissemination_test_table,
    set_workbook_uei,
)
from ..base_field_maps import (
    SheetFieldMap,
    WorkbookFieldInDissem,
)
from ..workbooklib.templates import sections_to_template_paths
from ..models import ELECFINDINGSTEXT as FindingsText
from audit.fixtures.excel import FORM_SECTIONS

import openpyxl as pyxl

import logging

logger = logging.getLogger(__name__)

mappings = [
    SheetFieldMap(
        "reference_number", "FINDINGREFNUMS", "finding_ref_number", None, str
    ),
    SheetFieldMap("text_of_finding", "TEXT", "finding_text", None, str),
    SheetFieldMap(
        "contains_chart_or_table", "CHARTSTABLES", WorkbookFieldInDissem, None, str
    ),
]


def _get_findings_texts(dbkey, year):
    return FindingsText.objects.filter(DBKEY=dbkey, AUDITYEAR=year).order_by(
        "SEQ_NUMBER"
    )


def generate_findings_text(audit_header, outfile):
    """
    Generates a findings text workbook for a given audit header.
    """
    logger.info(
        f"--- generate findings text {audit_header.DBKEY} {audit_header.AUDITYEAR} ---"
    )

    wb = pyxl.load_workbook(sections_to_template_paths[FORM_SECTIONS.FINDINGS_TEXT])
    set_workbook_uei(wb, audit_header.UEI)

    findings_texts = _get_findings_texts(audit_header.DBKEY, audit_header.AUDITYEAR)
    map_simple_columns(wb, mappings, findings_texts)

    wb.save(outfile)

    table = generate_dissemination_test_table(
        audit_header, "findings_text", mappings, findings_texts
    )
    table["singletons"]["auditee_uei"] = audit_header.UEI

    return (wb, table)
