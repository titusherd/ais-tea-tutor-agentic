"""Add a page break before the headline results table in generated DOCX files."""

from pathlib import Path
from tempfile import NamedTemporaryFile
from zipfile import ZIP_DEFLATED, ZipFile
import os
import xml.etree.ElementTree as ET

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
ET.register_namespace("w", W)


def add_break(path: Path, marker: str) -> None:
    with ZipFile(path, "r") as source:
        members = {info.filename: source.read(info.filename) for info in source.infolist()}

    root = ET.fromstring(members["word/document.xml"])
    changed = False
    for paragraph in root.iter(f"{{{W}}}p"):
        text = "".join(node.text or "" for node in paragraph.iter(f"{{{W}}}t"))
        if marker not in text:
            continue
        ppr = paragraph.find(f"{{{W}}}pPr")
        if ppr is None:
            ppr = ET.Element(f"{{{W}}}pPr")
            paragraph.insert(0, ppr)
        if ppr.find(f"{{{W}}}pageBreakBefore") is None:
            ppr.insert(0, ET.Element(f"{{{W}}}pageBreakBefore"))
            changed = True
        break

    if not changed:
        raise RuntimeError(f"Could not add page break before {marker!r} in {path}")

    members["word/document.xml"] = ET.tostring(
        root, encoding="utf-8", xml_declaration=True
    )
    with NamedTemporaryFile(prefix="docx_pagebreak_", suffix=".docx", delete=False) as tmp:
        tmp_path = Path(tmp.name)
    try:
        with ZipFile(tmp_path, "w", ZIP_DEFLATED) as target:
            for name, data in members.items():
                target.writestr(name, data)
        os.replace(tmp_path, path)
    finally:
        tmp_path.unlink(missing_ok=True)


if __name__ == "__main__":
    root = Path(__file__).resolve().parents[1] / "manuscripts"
    add_break(root / "paper1_working_paper.docx", "Table 2. R1 adjusted associations")
    add_break(root / "paper3_working_paper.docx", "Table 2. R3 adjusted associations")
    print("DOCX_PAGEBREAK_PASS")
