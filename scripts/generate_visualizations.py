#!/usr/bin/env python3
"""Generate lightweight SVG charts from captured SQL output files.

This script intentionally reads the small text files in outputs/ rather than the
full raw NHS prescribing CSV, so reviewers can regenerate the portfolio visuals
without downloading several GB of data or running PostgreSQL.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List
import html
import re

ROOT = Path(__file__).resolve().parents[1]
OUTPUTS_DIR = ROOT / "outputs"
VIS_DIR = ROOT / "visualizations"


@dataclass
class Row:
    label: str
    value: float
    secondary: float | None = None


def parse_psql_table(path: Path) -> List[dict[str, str]]:
    """Parse simple psql aligned table output into dictionaries."""
    lines = path.read_text(encoding="utf-8").splitlines()
    header_line = next((line for line in lines if "|" in line), None)
    if header_line is None:
        raise ValueError(f"No table header found in {path}")

    headers = [part.strip() for part in header_line.split("|")]
    rows: List[dict[str, str]] = []

    for line in lines[lines.index(header_line) + 1 :]:
        stripped = line.strip()
        if not stripped or stripped.startswith("("):
            continue
        if set(stripped.replace("+", "").replace("-", "")) == set():
            continue
        if "|" not in line:
            continue
        parts = [part.strip() for part in line.split("|")]
        if len(parts) != len(headers):
            continue
        rows.append(dict(zip(headers, parts)))

    if not rows:
        raise ValueError(f"No data rows parsed from {path}")
    return rows


def to_float(value: str) -> float:
    return float(re.sub(r"[^0-9.\-]", "", value))


def short_label(label: str, max_len: int = 34) -> str:
    label = label.replace("NHS ", "").replace(" INTEGRATED CARE BOARD", "")
    return label if len(label) <= max_len else label[: max_len - 1] + "…"


def money_millions(value: float) -> str:
    return f"£{value / 1_000_000:.1f}m"


def bar_chart_svg(
    title: str,
    subtitle: str,
    rows: Iterable[Row],
    output_path: Path,
    value_formatter=money_millions,
    width: int = 1100,
    row_height: int = 48,
) -> None:
    data = list(rows)
    if not data:
        raise ValueError(f"No rows supplied for {title}")

    margin_left = 330
    margin_right = 170
    margin_top = 110
    margin_bottom = 55
    chart_width = width - margin_left - margin_right
    height = margin_top + margin_bottom + row_height * len(data)
    max_value = max(row.value for row in data)

    colors = {
        "bg": "#0d1117",
        "panel": "#161b22",
        "text": "#e6edf3",
        "muted": "#8b949e",
        "grid": "#30363d",
        "bar": "#2f81f7",
        "bar_alt": "#56d364",
    }

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-label="{html.escape(title)}">',
        f'<rect width="100%" height="100%" rx="20" fill="{colors["bg"]}"/>',
        f'<rect x="20" y="20" width="{width - 40}" height="{height - 40}" rx="16" fill="{colors["panel"]}" stroke="{colors["grid"]}"/>',
        f'<text x="44" y="58" fill="{colors["text"]}" font-family="Arial, Helvetica, sans-serif" font-size="28" font-weight="700">{html.escape(title)}</text>',
        f'<text x="44" y="87" fill="{colors["muted"]}" font-family="Arial, Helvetica, sans-serif" font-size="16">{html.escape(subtitle)}</text>',
    ]

    for i, row in enumerate(data):
        y = margin_top + i * row_height
        bar_width = 0 if max_value == 0 else (row.value / max_value) * chart_width
        color = colors["bar"] if i % 2 == 0 else colors["bar_alt"]
        label = short_label(row.label)
        parts.extend(
            [
                f'<text x="44" y="{y + 26}" fill="{colors["text"]}" font-family="Arial, Helvetica, sans-serif" font-size="16">{html.escape(label)}</text>',
                f'<rect x="{margin_left}" y="{y + 8}" width="{chart_width}" height="24" rx="6" fill="#21262d"/>',
                f'<rect x="{margin_left}" y="{y + 8}" width="{bar_width:.1f}" height="24" rx="6" fill="{color}"/>',
                f'<text x="{margin_left + chart_width + 18}" y="{y + 26}" fill="{colors["text"]}" font-family="Arial, Helvetica, sans-serif" font-size="15" font-weight="700">{html.escape(value_formatter(row.value))}</text>',
            ]
        )

    parts.extend(
        [
            f'<text x="44" y="{height - 26}" fill="{colors["muted"]}" font-family="Arial, Helvetica, sans-serif" font-size="13">Source: generated from committed SQL output files in outputs/</text>',
            "</svg>",
        ]
    )
    output_path.write_text("\n".join(parts) + "\n", encoding="utf-8")


def main() -> None:
    VIS_DIR.mkdir(exist_ok=True)

    chemicals = parse_psql_table(OUTPUTS_DIR / "01_top_chemicals_by_cost.txt")[:10]
    icbs = parse_psql_table(OUTPUTS_DIR / "03_top_icbs_by_cost.txt")[:10]
    cost_per_item = parse_psql_table(OUTPUTS_DIR / "07_cost_per_item_by_chemical.txt")[:10]

    bar_chart_svg(
        title="Top BNF chemical substances by actual cost",
        subtitle="January 2026 NHS English Prescribing Dataset · top 10 by total actual cost",
        rows=[Row(r["bnf_chemical_substance"], to_float(r["total_actual_cost"])) for r in chemicals],
        output_path=VIS_DIR / "top_chemicals_by_cost.svg",
    )

    bar_chart_svg(
        title="Top ICBs by prescribing actual cost",
        subtitle="January 2026 NHS English Prescribing Dataset · top 10 ICBs by total actual cost",
        rows=[Row(r["icb_name"], to_float(r["total_actual_cost"])) for r in icbs],
        output_path=VIS_DIR / "top_icbs_by_cost.svg",
    )

    bar_chart_svg(
        title="Highest average cost per item by BNF chemical",
        subtitle="January 2026 NHS English Prescribing Dataset · top 10 chemicals by average cost per item",
        rows=[Row(r["bnf_chemical_substance"], to_float(r["avg_cost_per_item"])) for r in cost_per_item],
        output_path=VIS_DIR / "highest_cost_per_item.svg",
        value_formatter=lambda v: f"£{v:,.2f}",
    )

    generated = sorted(p.relative_to(ROOT) for p in VIS_DIR.glob("*.svg"))
    print("Generated visualizations:")
    for path in generated:
        print(f"- {path}")


if __name__ == "__main__":
    main()
