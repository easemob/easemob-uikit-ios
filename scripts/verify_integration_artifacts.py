#!/usr/bin/env python3
"""Check resources and AMR embedding in a built iOS .app or .xcarchive."""

import argparse
import plistlib
from pathlib import Path
import subprocess
import sys


def read_plist(path):
    # Xcode may compile Localizable.strings and privacy manifests to binary plists.
    data = subprocess.check_output(["plutil", "-convert", "xml1", "-o", "-", str(path)])
    return plistlib.loads(data)


def verify(artifact):
    if artifact.suffix == ".xcarchive":
        apps = list((artifact / "Products/Applications").glob("*.app"))
        if len(apps) != 1:
            raise ValueError("Expected one application in the archive")
        artifact = apps[0]
    if artifact.suffix != ".app" or not artifact.is_dir():
        raise ValueError("Provide an existing .app or .xcarchive")

    root = Path(__file__).resolve().parents[1]
    source = root / "Sources/EaseChatUIKit/Classes/UI/Resources"
    bundles = list(artifact.rglob("EaseChatResource.bundle"))
    # Ignore extension/test apps: each executable has its own resource ownership.
    bundles = [path for path in bundles if "PlugIns" not in path.relative_to(artifact).parts]
    if not bundles:
        raise ValueError("EaseChatResource.bundle is missing from the app")
    expected = {path.name for path in (source / "EaseChatResource.bundle").glob("*.png")}
    # Xcode can include a copy in both the app and its generated package-product
    # framework. Validate every copy, including its contents, instead of choosing one.
    for bundle in bundles:
        location = bundle.relative_to(artifact)
        actual = {path.name for path in bundle.glob("*.png")}
        if expected != actual:
            raise ValueError(f"PNG inventory differs in {location}: missing={sorted(expected - actual)}, extra={sorted(actual - expected)}")
        for name in expected:
            if (bundle / name).read_bytes() != (source / "EaseChatResource.bundle" / name).read_bytes():
                raise ValueError(f"Image contents differ in {location}: {name}")
        for language in ["en", "zh-Hans"]:
            relative = Path(f"{language}.lproj/Localizable.strings")
            if read_plist(bundle / relative) != read_plist(source / "EaseChatResource.bundle" / relative):
                raise ValueError(f"Localized strings differ in {location}: {language}")

    privacy = read_plist(source / "PrivacyInfo.xcprivacy")
    manifests = [path for path in artifact.rglob("PrivacyInfo.xcprivacy")
                 if "PlugIns" not in path.relative_to(artifact).parts]
    if not any(read_plist(path) == privacy for path in manifests):
        raise ValueError("EaseChatUIKit privacy manifest is missing or changed")

    codec = artifact / "Frameworks/AMRCodec.framework/AMRCodec"
    if not codec.is_file():
        raise ValueError("Dynamic AMRCodec.framework is not embedded in the app")
    linkage = subprocess.check_output(["otool", "-L", str(codec)], text=True)
    if "@rpath/AMRCodec.framework/AMRCodec" not in linkage:
        raise ValueError("AMRCodec has an unexpected install name")
    print(f"PASS: {len(expected)} images per bundle, both localizations, privacy manifest, and embedded AMRCodec")
    print(f"Validated {len(bundles)} resource bundle copies:")
    for bundle in bundles:
        print(f"  {bundle.relative_to(artifact)}")
    print("Signing, runtime loading, and audio playback require a signed device run.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("artifact", type=Path)
    args = parser.parse_args()
    try:
        verify(args.artifact.resolve())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
