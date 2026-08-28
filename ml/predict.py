"""
predict.py
----------
Loads the trained expense-category model and exposes a single predict()
helper returning (category, confidence). Used by app.py's /predict endpoint
and usable standalone from the command line for quick checks.

    python predict.py "Uber ride to client office"
"""

import os
import sys

import joblib

MODEL_PATH = os.path.join(os.path.dirname(__file__), "model", "expense_classifier.pkl")

_model = None


def _load():
    global _model
    if _model is None:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(
                f"Model not found at {MODEL_PATH}. Run: python train_model.py")
        _model = joblib.load(MODEL_PATH)
    return _model


def predict(text):
    """Return (category, confidence 0..1) for a piece of expense text."""
    text = (text or "").strip()
    if not text:
        return None, 0.0
    model = _load()
    category = model.predict([text])[0]
    confidence = 0.0
    # LogisticRegression exposes calibrated-ish probabilities via predict_proba.
    if hasattr(model, "predict_proba"):
        proba = model.predict_proba([text])[0]
        confidence = float(max(proba))
    return str(category), confidence


if __name__ == "__main__":
    q = " ".join(sys.argv[1:]) or "Starbucks coffee with client"
    cat, conf = predict(q)
    print(f"text      : {q}")
    print(f"category  : {cat}")
    print(f"confidence: {conf:.4f}")
