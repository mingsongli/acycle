#!/usr/bin/env python3
"""Read-only integrity and physical-layout audit for COCO publication output."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET

from PIL import Image
from pypdf import PdfReader


WORD_NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "wp": "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def audit_docx(path: Path) -> None:
    require(path.is_file(), f"Missing Word report: {path}")
    with zipfile.ZipFile(path) as archive:
        document = ET.fromstring(archive.read("word/document.xml"))
    page_sizes = document.findall(".//w:sectPr/w:pgSz", WORD_NS)
    require(page_sizes, f"No Word page geometry found: {path}")
    for page in page_sizes:
        width_mm = int(page.attrib[f"{{{WORD_NS['w']}}}w"]) / 1440 * 25.4
        height_mm = int(page.attrib[f"{{{WORD_NS['w']}}}h"]) / 1440 * 25.4
        require(abs(width_mm - 210) <= 0.2 and abs(height_mm - 297) <= 0.2,
                f"Non-A4 Word section in {path}: {width_mm:.3f} x {height_mm:.3f} mm")
    for extent in document.findall(".//wp:extent", WORD_NS):
        width_mm = int(extent.attrib["cx"]) / 36000
        require(width_mm <= 180.1,
                f"Embedded figure exceeds 180 mm in {path}: {width_mm:.3f} mm")


def audit_png(path: Path) -> None:
    with Image.open(path) as image:
        width_pixels = image.width
        dpi = image.info.get("dpi")
    if dpi and dpi[0] > 0:
        width_mm = width_pixels / dpi[0] * 25.4
    else:
        width_mm = width_pixels / 600 * 25.4
    require(0 < width_mm <= 180.5,
            f"PNG width exceeds 180 mm at recorded/declared 600 dpi: {path} ({width_mm:.3f} mm)")


def audit_pdf(path: Path) -> None:
    reader = PdfReader(str(path))
    require(len(reader.pages) == 1, f"Expected one-page figure PDF: {path}")
    box = reader.pages[0].mediabox
    width_mm = float(box.width) / 72 * 25.4
    require(0 < width_mm <= 180.05,
            f"Vector PDF width exceeds 180 mm: {path} ({width_mm:.3f} mm)")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("result_root", type=Path)
    args = parser.parse_args()
    root = args.result_root.expanduser().resolve()
    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    cases = manifest.get("cases", [])
    require(manifest.get("status") == "complete", "Suite manifest is not complete")
    require(len(cases) == 6, f"Expected six cases; found {len(cases)}")

    method_count = 0
    figure_count = 0
    for case in cases:
        require(case.get("status") == "complete", f"Case is not complete: {case.get('id')}")
        case_dir = root / case["case_dir"]
        audit_docx(case_dir / "case_report.docx")
        with (case_dir / "summary.csv").open(encoding="utf-8-sig", newline="") as handle:
            rows = list(csv.DictReader(handle))
        require(len(rows) == 4, f"Expected four method rows for {case.get('id')}")
        require(all(row.get("status") == "complete" for row in rows),
                f"Incomplete summary row for {case.get('id')}")
        methods = case.get("methods", [])
        require(len(methods) == 4, f"Expected four method manifests for {case.get('id')}")
        for method in methods:
            method_count += 1
            require(method.get("status") == "complete", "Method manifest is not complete")
            require(int(method.get("nsim")) == 9999, "A formal method does not use NSIM=9999")
            for field in ("result_file", "workbook", "conclusion_file"):
                require((root / method[field]).is_file(), f"Missing method artifact: {method[field]}")
        figures = case.get("figures", [])
        require(len(figures) == 12, f"Expected twelve figure entries for {case.get('id')}")
        for figure in figures:
            figure_count += 1
            require(float(figure.get("width_mm")) <= 180, "Manifest figure width exceeds 180 mm")
            audit_png(root / figure["path"])
            audit_pdf(root / figure["pdf_path"])
            require((root / figure["fig_path"]).is_file(), "Editable FIG artifact is missing")

    audit_docx(root / "COCO_publication_validation_report.docx")

    inventory_path = root / "artifact_sha256.csv"
    with inventory_path.open(encoding="utf-8-sig", newline="") as handle:
        inventory = list(csv.DictReader(handle))
    require(inventory, "Artifact inventory is empty")
    inventoried = set()
    for row in inventory:
        relative = row["Relative_path"]
        path = root / relative
        require(path.is_file(), f"Inventoried artifact is missing: {relative}")
        require(path.stat().st_size == int(row["Bytes"]), f"Size mismatch: {relative}")
        require(sha256(path) == row["SHA256"], f"SHA-256 mismatch: {relative}")
        inventoried.add(relative)
    require("COCO_publication_validation_report.docx" in inventoried,
            "Combined Word report is absent from checksum inventory")
    for case in cases:
        require(f"{case['case_dir']}/case_report.docx" in inventoried,
                f"Case Word report is absent from inventory: {case['id']}")

    print(
        f"ARTIFACT_AUDIT_PASS cases={len(cases)} methods={method_count} "
        f"figures={figure_count} checksums={len(inventory)}"
    )


if __name__ == "__main__":
    main()
