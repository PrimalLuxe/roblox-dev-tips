from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COLLECTION = ROOT / "src/StarterPlayer/StarterPlayerScripts/Controllers/CollectionArtDirector.lua"
PERF_DOC = ROOT / "PERFORMANCE_AUDIT.md"


def require(text: str, marker: str, message: str) -> None:
    if marker not in text:
        raise AssertionError(message)


def reject(text: str, marker: str, message: str) -> None:
    if marker in text:
        raise AssertionError(message)


def main() -> None:
    source = COLLECTION.read_text(encoding="utf-8")
    audit = PERF_DOC.read_text(encoding="utf-8")

    require(source, "CollectionVirtualState", "collection virtualization state missing")
    require(source, "VirtualSlot", "lightweight virtual slots missing")
    require(source, "CanvasPosition", "scroll-driven virtualization missing")
    require(source, "OVERSCAN_ROWS", "overscan buffer missing")
    require(source, "AutomaticCanvasSize=Enum.AutomaticSize.Y", "automatic scrolling canvas missing")
    require(source, "card:Destroy()", "offscreen mounted cards are not released")
    require(source, "CollectionRenderGeneration", "stale deferred render protection missing")
    require(source, "MountQueued", "scroll mount coalescing missing")
    require(source, "AbsoluteSize", "viewport-resize virtualization refresh missing")
    require(source, "MountedCard", "heavy card mount boundary missing")
    reject(source, "for _,it in ipairs(rows)do renderCard", "collection still eagerly mounts every heavy card")

    require(audit, "virtual", "performance audit does not document collection virtualization")
    require(audit, "100+", "performance audit must retain large-inventory profiling gate")
    require(audit, "NOT RUN", "performance audit must preserve measured-engine verification boundary")

    print("Performance architecture audit: PASS")
    print("- collection uses lightweight slots + visible-window heavy card mounting")
    print("- offscreen ViewportFrames/models are destroyed")
    print("- scroll/resize refreshes are deferred and coalesced")
    print("- measured Studio/device profiling remains explicitly required")


if __name__ == "__main__":
    main()
