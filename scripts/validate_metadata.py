#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
schema_path = ROOT / "metadata" / "image.schema.json"
metadata_dir = ROOT / "metadata"

try:
    import yaml
except ImportError:
    print("PyYAML is required for metadata validation.")
    sys.exit(1)

schema = json.loads(schema_path.read_text(encoding="utf-8"))

required = set(schema["required"])
security_required = set(schema["properties"]["security"]["required"])

errors = []

for path in sorted(metadata_dir.glob("*.yaml")):
    data = yaml.safe_load(path.read_text(encoding="utf-8"))

    missing = required - set(data or {})
    if missing:
        errors.append(f"{path}: missing fields: {', '.join(sorted(missing))}")
        continue

    security = data.get("security", {})
    missing_security = security_required - set(security)
    if missing_security:
        errors.append(
            f"{path}: missing security fields: {', '.join(sorted(missing_security))}"
        )

    if security.get("profile") != "cis-l1-aligned":
        errors.append(f"{path}: security.profile must be cis-l1-aligned")

    for field in ("non_root", "sbom", "provenance", "signing"):
        if security.get(field) is not True:
            errors.append(f"{path}: security.{field} must be true")

if errors:
    print("\n".join(errors))
    sys.exit(1)

print("Metadata validation passed.")
