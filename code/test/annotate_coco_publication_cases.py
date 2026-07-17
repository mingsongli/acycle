#!/usr/bin/env python3
"""Add prewritten, result-specific interpretation notes to COCO case manifests."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import tempfile


NOTES = {
    "rednoise_long": [
        "Both formal primary analyses are negative (cvCOCO p_robust = 0.4602; Adaptive global p = 0.6540), as expected for this long pure-noise control.",
        "The best-rate labels have no physical meaning in a negative control and must not be interpreted as sedimentation-rate estimates.",
    ],
    "rednoise_short": [
        "Both formal primary analyses are negative (cvCOCO p_robust = 0.3803; Adaptive global p = 0.6620), despite the low power expected from only about 100 observations per held-out half.",
        "In the red=0 sensitivity run, a smaller local Adaptive p-value is erased by full rate-search correction; this illustrates why the global result is primary.",
    ],
    "signal_4_to_6": [
        "The expected rates are accurately localized (4.00 and 5.98 cm/kyr), but the primary full-flow tests are not significant (cvCOCO p_robust = 0.2207; Adaptive global p = 0.1973). Rate recovery and hypothesis rejection are distinct claims.",
        "The deterministic depth-midpoint split places the true 4-to-6 rate transition inside one half, while cvCOCO assumes one constant rate within each half; full-record Adaptive COCO likewise assumes one rate. This positive-control failure is therefore an explicit model/power limitation, not evidence that the recovered rates are wrong.",
    ],
    "newark_late_triassic": [
        "This is the only robust confirmatory positive in the six-case suite: cvCOCO p_robust = 0.0072 and secondary p_sym = 0.0004, with both directions using all nine periods.",
        "The held-out rates (14.35 and 14.55 cm/kyr) and Adaptive rate (14.15 cm/kyr) agree with the expected 10-15 cm/kyr range. The association is consistent with astronomical pacing but is not unconditional proof of causation.",
    ],
    "site1262_eocene": [
        "The expected approximately 1.2 cm/kyr rate is localized (held-out 0.96/1.19; Adaptive 1.20), but neither formal test is significant (cvCOCO p_robust = 0.4198; Adaptive global p = 0.1750).",
        "Small local Adaptive p-values do not override the global search-corrected result. One frozen cv direction also has only eight nonzero-weight periods, which is reported as a partial-target qualification.",
    ],
    "givetian_dd14": [
        "The rate is localized near the expected value (Adaptive 8.00 cm/kyr; one held-out direction 8.25 cm/kyr), but the two directions disagree in strength.",
        "A-to-B has p_B = 0.0293 whereas B-to-A has p_A = 0.3175; therefore p_robust = 0.3175 and the confirmatory decision is negative. Adaptive local p = 0.0086 is also subordinate to its global p = 0.2480.",
    ],
}


def write_atomic(path: Path, value: dict) -> None:
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.stem}.", suffix=".tmp", dir=path.parent
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(value, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
        os.replace(temporary_name, path)
    except Exception:
        try:
            os.unlink(temporary_name)
        except OSError:
            pass
        raise


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("result_root", type=Path)
    args = parser.parse_args()
    root = args.result_root.expanduser().resolve()
    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    count = 0
    for case in manifest.get("cases", []):
        case_id = case.get("id")
        if case_id not in NOTES:
            raise KeyError(f"No interpretation note registered for case {case_id}")
        path = root / case["case_dir"] / "case_manifest.json"
        value = json.loads(path.read_text(encoding="utf-8"))
        value["notes"] = NOTES[case_id]
        write_atomic(path, value)
        count += 1
    if count != 6:
        raise AssertionError(f"Expected six annotated cases; found {count}")
    print(f"ANNOTATION_PASS cases={count}")


if __name__ == "__main__":
    main()
