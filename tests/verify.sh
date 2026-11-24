#!/usr/bin/env bash
# tests/verify.sh — this realm's views against ground truth read straight from git.
#
#   APPLIANCE=http://127.0.0.1:11043 AUTH=user:pass tests/verify.sh
#
# Keyless: the subject is a public repository pinned at one commit (spring-petclinic, Java), so
# every figure below is fixed and is re-derived here from the same commit with git, never typed in.
#   L1  every view of this realm answers BY NAME, with no error. Views that need an indexed project
#       (search, ask) must answer cleanly before any index exists; AnswerFromCode, which writes with
#       a model over ids an index gives, is named and skipped.
#   L2  figures reconciled with the checkout: Java files per ProjectLanguages, where Owner is
#       declared, GET and POST routes against the @GetMapping/@PostMapping lines, the tests for
#       OwnerController, the beans PushChecks names, and LargestFunctions' bound.
#   L3  a one-file question stays on that file: RulesHeadroom and PushChecks on one path report
#       that file only. (The source-tree kind makes no remote API calls to count; a path equality
#       is applied before parsing, so these read one file of the fifty.)
# Needs git and python3 on the host. Last line on success: ALL CHECKS PASS. Exit 1 on any failure.
set -eu
cd "$(dirname "$0")/.."
: "${AUTH:?set AUTH=user:pass}"
APPLIANCE="${APPLIANCE:-http://127.0.0.1:11043}"
REPO=https://github.com/spring-projects/spring-petclinic
SHA=500158f732419217507c7656904b8e6aa1bcc0d6
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
git -C "$WORK" init -q && git -C "$WORK" fetch -q --depth 1 "$REPO" "$SHA" && git -C "$WORK" checkout -q FETCH_HEAD
python3 - "$APPLIANCE" "$AUTH" "$REPO@$SHA" "$WORK" <<'PY'
import base64, glob, json, os, re, sys, urllib.request, urllib.error
base, auth, key, work = sys.argv[1:5]
hdr = {"Authorization": "Basic " + base64.b64encode(auth.encode()).decode(), "Content-Type": "application/json"}
fails = []

def view(name, args):
    req = urllib.request.Request(f"{base}/api/v1/views/{name}/invoke", headers=hdr,
                                 data=json.dumps({"args": args}).encode())
    try:
        with urllib.request.urlopen(req, timeout=600) as r:
            d = json.load(r)
    except urllib.error.HTTPError as e:
        return None, f"HTTP {e.code} {e.read().decode()[:200]}"
    if d.get("error"):
        return None, str(d["error"])[:200]
    rows = d.get("data") if isinstance(d.get("data"), list) else d.get("rows")
    return (rows if isinstance(rows, list) else None), (None if isinstance(rows, list) else f"no rows in {str(d)[:160]}")

def check(what, ok, detail=""):
    print(("  ok   " if ok else "  FAIL ") + what + (f": {detail}" if detail and not ok else ""))
    if not ok: fails.append(what)

OWNER_DIR = "src/main/java/org/springframework/samples/petclinic/owner"
CONTROLLER = OWNER_DIR + "/OwnerController.java"
ARGS = {
    "RulesHeadroom": {"path": CONTROLLER}, "PushChecks": {"path": CONTROLLER},
    "TestsFor": {"type": "OwnerController"},
    "WhereDefined": {"name": "Owner"}, "WhoCalls": {"name": "findById"},
    "WhoUses": {"name": "Owner"}, "Impact": {"name": "Owner"}, "PartContents": {"part": OWNER_DIR},
    "SearchCode": {"query": "find an owner by last name"}, "SearchAndCallers": {"query": "find an owner by last name"},
    "MatchDeclarations": {"terms": "owner"},
    "Declaration": {"id": key.replace("https://", "") + "!" + CONTROLLER + "#class:OwnerController"},
    "Declarations": {"ids": key.replace("https://", "") + "!" + CONTROLLER + "#class:OwnerController"},
    "AskContext": {"ids": key.replace("https://", "") + "!" + CONTROLLER + "#class:OwnerController"},
}
SKIP = {"AnswerFromCode": "writes an answer with a model from ids an index gives; not run here"}
NO_PROJECT = {"IndexedProjects"}

print(f"== L1: every view answers by name ({key})")
results = {}
names = sorted({m.group(1) for f in glob.glob("views/*.yml") for m in re.finditer(r"^- name:\s*(\S+)", open(f).read(), re.M)})
for name in names:
    if name in SKIP:
        print(f"  skip {name}: {SKIP[name]}"); continue
    args = dict(ARGS.get(name, {}))
    if name not in NO_PROJECT: args["project"] = key
    rows, err = view(name, args)
    results[name] = rows
    check(f"{name} answers", err is None, err or "")
    if err is None: print(f"       {name}: {len(rows)} row(s)")

print("== L2: reconciled with the checkout")
java = [p for p in glob.glob(f"{work}/**/*.java", recursive=True)]
rel = lambda p: os.path.relpath(p, work)
langs = {r.get("language"): r for r in results.get("ProjectLanguages") or []}
check("ProjectLanguages: Java files = git's .java files", (langs.get("java") or {}).get("files") == len(java),
      f"view {(langs.get('java') or {}).get('files')}, git {len(java)}")
check("ProjectLanguages: no other language (the commit has none the kind reads)", set(langs) == {"java"}, str(set(langs)))
owner = results.get("WhereDefined") or []
check("WhereDefined(Owner): one class, in owner/Owner.java",
      len(owner) == 1 and owner[0].get("kind") == "class" and owner[0].get("file") == OWNER_DIR + "/Owner.java", str(owner)[:200])
main = [p for p in java if rel(p).startswith("src/main/")]
def annotated(a):
    return sum(len(re.findall(r"^\s*@" + a + r"\b", open(p).read(), re.M)) for p in main)
routes = results.get("Routes") or []
for method, ann in (("GET", "GetMapping"), ("POST", "PostMapping")):
    seen = len([r for r in routes if r.get("role") == "route" and r.get("method") == method and not r.get("test")])
    check(f"Routes: {method} routes = @{ann} lines in main source", seen == annotated(ann), f"view {seen}, source {annotated(ann)}")
tests = {r.get("test") for r in results.get("TestsFor") or []}
check("TestsFor(OwnerController) names OwnerControllerTests", "OwnerControllerTests" in tests, str(tests))
beans = [r for r in results.get("PushChecks") or [] if r.get("rule") == "bean or listener"]
check("PushChecks: OwnerController's @Controller is named", any("OwnerController" in str(r.get("subject")) for r in beans), str(beans)[:200])
check("LargestFunctions: at most 25 rows, longest first",
      0 < len(results.get("LargestFunctions") or []) <= 25 and
      [r["lines"] for r in results["LargestFunctions"]] == sorted([r["lines"] for r in results["LargestFunctions"]], reverse=True))

print("== L3: a one-file question stays on that file")
files = {r.get("subject") for r in results.get("RulesHeadroom") or [] if r.get("rule") == "lines in the file"}
check("RulesHeadroom: one file measured, the one asked for", files == {CONTROLLER}, str(files))
stray = [r for r in results.get("PushChecks") or [] if r.get("rule") == "bean or listener" and not str(r.get("subject", "")).startswith("OwnerController")]
check("PushChecks: every bean row is the file's own", not stray, str(stray)[:200])

if fails:
    print(f"{len(fails)} check(s) FAILED: " + "; ".join(fails)); sys.exit(1)
print("ALL CHECKS PASS")
PY
