"""
Anomaly verification for the seeded demo employees.

Reads each employee's REAL history straight out of MySQL (exactly the query
ExpenseDAO.listPriorAmounts uses) and posts it to the running Flask /anomaly
endpoint, so every verdict below is produced by the live Isolation Forest.
Nothing is hardcoded or asserted into existence.
"""
import json
import subprocess
import urllib.request

EMAILS = [
    "aarav@claimsense.com",
    "riya@claimsense.com",
    "arjun@claimsense.com",
    "ananya@claimsense.com",
    "kabir@claimsense.com",
]


def sql(query):
    out = subprocess.run(
        ["docker", "exec", "claimsense-mysql", "mysql", "-uroot", "-proot",
         "claimsense_ai", "-N", "-B", "-e", query],
        capture_output=True, text=True,
    )
    return [l for l in out.stdout.splitlines() if l.strip()]


def history_for(email):
    # Same shape as ExpenseDAO.listPriorAmounts: all of the user's amounts.
    rows = sql(
        "SELECT e.amount FROM expenses e JOIN users u ON u.user_id = e.user_id "
        f"WHERE u.email = '{email}' ORDER BY e.created_at"
    )
    return [float(r) for r in rows]


def anomaly(amount, category, history):
    body = json.dumps({"amount": amount, "category": category, "history": history}).encode()
    req = urllib.request.Request(
        "http://localhost:5000/anomaly", data=body,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.loads(r.read().decode())


print(f"{'employee':<26}{'n':>4}  {'test':<26}{'status':<20}{'score'}")
print("-" * 92)

failures = []
for email in EMAILS:
    hist = history_for(email)
    name = email.split("@")[0]

    for label, amt, expected in [
        ("normal Rs.500", 500.0, "NORMAL"),
        ("high Rs.18,000", 18000.0, "POTENTIAL ANOMALY"),
    ]:
        res = anomaly(amt, "Food", hist)
        score = res.get("score")
        score_s = f"{score:.4f}" if isinstance(score, float) else str(score)
        ok = res.get("status") == expected
        print(f"{name:<26}{len(hist):>4}  {label:<26}{res.get('status'):<20}{score_s}"
              + ("" if ok else f"   <-- expected {expected}"))
        if not ok:
            failures.append((email, label, res.get("status"), expected))

# Insufficient-history scenario: fewer than MIN_HISTORY=5 prior amounts.
res = anomaly(500.0, "Food", [420.0, 610.0, 380.0, 700.0])
print(f"{'(4-point history)':<26}{4:>4}  {'insufficient history':<26}{res.get('status'):<20}{res.get('score')}")
if res.get("status") != "INSUFFICIENT DATA":
    failures.append(("synthetic", "4-point history", res.get("status"), "INSUFFICIENT DATA"))

res = anomaly(500.0, "Food", [])
print(f"{'(empty history)':<26}{0:>4}  {'insufficient history':<26}{res.get('status'):<20}{res.get('score')}")
if res.get("status") != "INSUFFICIENT DATA":
    failures.append(("synthetic", "empty history", res.get("status"), "INSUFFICIENT DATA"))

print("-" * 92)
print("ALL EXPECTED" if not failures else f"MISMATCHES: {failures}")
