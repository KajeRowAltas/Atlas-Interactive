from __future__ import annotations

import zipfile
from dataclasses import dataclass
from typing import Iterable, Optional
from xml.etree import ElementTree as ET


_NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


@dataclass(frozen=True)
class XlsxTable:
    headers: list[str]
    rows: list[dict[str, Optional[str]]]


def _col_letters_to_index(col: str) -> int:
    idx = 0
    for ch in col.upper():
        idx = idx * 26 + (ord(ch) - ord("A") + 1)
    return idx - 1


def _cell_ref_to_col_index(cell_ref: str) -> int:
    col = []
    for ch in cell_ref:
        if ch.isalpha():
            col.append(ch)
        else:
            break
    return _col_letters_to_index("".join(col))


def _load_shared_strings(z: zipfile.ZipFile) -> list[str]:
    if "xl/sharedStrings.xml" not in z.namelist():
        return []
    root = ET.fromstring(z.read("xl/sharedStrings.xml"))
    shared: list[str] = []
    for si in root.findall("m:si", _NS):
        texts = [t.text or "" for t in si.findall(".//m:t", _NS)]
        shared.append("".join(texts))
    return shared


def _cell_value(cell: ET.Element, shared_strings: list[str]) -> Optional[str]:
    cell_type = cell.attrib.get("t")
    if cell_type == "inlineStr":
        is_el = cell.find("m:is", _NS)
        if is_el is None:
            return None
        texts = [t.text or "" for t in is_el.findall(".//m:t", _NS)]
        return "".join(texts) if texts else None

    v = cell.find("m:v", _NS)
    if v is None or v.text is None:
        return None
    raw = v.text
    if cell_type == "s":
        try:
            return shared_strings[int(raw)]
        except Exception:  # noqa: BLE001
            return raw
    return raw


def read_first_sheet_table(path: str) -> XlsxTable:
    """
    Read a simple export-style XLSX sheet (single header row + data rows).

    This intentionally avoids non-stdlib dependencies (e.g., openpyxl) so it can
    run in constrained environments.
    """
    with zipfile.ZipFile(path) as z:
        shared = _load_shared_strings(z)
        sheet = ET.fromstring(z.read("xl/worksheets/sheet1.xml"))
        rows = sheet.findall("m:sheetData/m:row", _NS)
        if not rows:
            return XlsxTable(headers=[], rows=[])

        def parse_row(row: ET.Element, ncols: int) -> list[Optional[str]]:
            values: list[Optional[str]] = [None] * ncols
            for cell in row.findall("m:c", _NS):
                cell_ref = cell.attrib.get("r")
                if not cell_ref:
                    continue
                col_index = _cell_ref_to_col_index(cell_ref)
                if 0 <= col_index < ncols:
                    values[col_index] = _cell_value(cell, shared)
            return values

        header_vals = [_cell_value(c, shared) for c in rows[0].findall("m:c", _NS)]
        headers = [h for h in header_vals if h is not None]
        ncols = len(headers)
        if ncols == 0:
            return XlsxTable(headers=[], rows=[])

        out_rows: list[dict[str, Optional[str]]] = []
        for row in rows[1:]:
            values = parse_row(row, ncols)
            if not any(v not in (None, "") for v in values):
                continue
            out_rows.append({headers[i]: values[i] for i in range(ncols)})

        return XlsxTable(headers=headers, rows=out_rows)


def iter_rows(path: str) -> Iterable[dict[str, Optional[str]]]:
    return read_first_sheet_table(path).rows
