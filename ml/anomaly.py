"""
anomaly.py
----------
Amount anomaly detection using scikit-learn's IsolationForest (§22).

The model is fit on the fly from the employee's own historical expense amounts
for the relevant context (passed in by the Java service). This keeps detection
personal and avoids a stale global model.

Rules the rest of the system relies on:
  * Insufficient history  -> status "INSUFFICIENT DATA"  (never blocks submission)
  * Clear outlier         -> status "POTENTIAL ANOMALY"  (wording is deliberate:
                             we say *potential anomaly*, never "fraud")
  * Otherwise             -> status "NORMAL"

Returns a dict: {status, score, message}
"""

import numpy as np
from sklearn.ensemble import IsolationForest

# Need a minimum number of historical points before an outlier model is
# meaningful. Below this we honestly report that we cannot analyse.
MIN_HISTORY = 5
RANDOM_STATE = 42


def detect(amount, category, history):
    """
    amount   : float  - the new expense amount to score
    category : str    - category label (used only for the message)
    history  : list[float] - the employee's prior amounts in this context
    """
    try:
        amount = float(amount)
    except (TypeError, ValueError):
        return {"status": "INSUFFICIENT DATA", "score": None,
                "message": "Insufficient data for anomaly analysis"}

    clean = []
    for h in (history or []):
        try:
            v = float(h)
            if v > 0:
                clean.append(v)
        except (TypeError, ValueError):
            continue

    if len(clean) < MIN_HISTORY:
        return {
            "status": "INSUFFICIENT DATA",
            "score": None,
            "message": "Insufficient data for anomaly analysis",
        }

    X = np.array(clean, dtype=float).reshape(-1, 1)

    # contamination='auto' lets the model infer the outlier fraction rather than
    # us hard-coding one.
    model = IsolationForest(
        n_estimators=100,
        contamination="auto",
        random_state=RANDOM_STATE,
    )
    model.fit(X)

    point = np.array([[amount]], dtype=float)
    pred = int(model.predict(point)[0])          # -1 outlier, 1 inlier
    # score_samples: lower (more negative) => more anomalous.
    raw_score = float(model.score_samples(point)[0])

    if pred == -1:
        avg = float(np.mean(clean))
        return {
            "status": "POTENTIAL ANOMALY",
            "score": raw_score,
            "message": (
                f"Potential anomaly detected: amount is unusual versus your "
                f"typical {category or 'expense'} spend (avg ~{avg:.0f})."
            ),
        }

    return {
        "status": "NORMAL",
        "score": raw_score,
        "message": "Amount is within the normal range.",
    }
