"""
train_model.py
--------------
Trains the expense-category classifier used by the /predict endpoint.

Pipeline:  TfidfVectorizer  ->  LogisticRegression
Split:     80 / 20 stratified, random_state=42 (reproducible)
Output:    model/expense_classifier.pkl   (joblib)

The script prints the ACTUAL metrics computed on the held-out test set - nothing
here is hard-coded. Re-running with the same dataset yields the same numbers.

Run:
    python train_model.py
"""

import os

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (accuracy_score, classification_report,
                             f1_score, precision_score, recall_score)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

HERE = os.path.dirname(__file__)
DATASET = os.path.join(HERE, "dataset.csv")
MODEL_DIR = os.path.join(HERE, "model")
MODEL_PATH = os.path.join(MODEL_DIR, "expense_classifier.pkl")
RANDOM_STATE = 42


def main():
    if not os.path.exists(DATASET):
        raise SystemExit(
            f"Dataset not found at {DATASET}. Run: python generate_dataset.py")

    df = pd.read_csv(DATASET)
    df = df.dropna(subset=["text", "category"])
    X = df["text"].astype(str)
    y = df["category"].astype(str)

    print(f"Loaded {len(df)} labelled examples across {y.nunique()} categories.")
    print("Class distribution:")
    print(y.value_counts().to_string())
    print("-" * 60)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=RANDOM_STATE, stratify=y)
    print(f"Train: {len(X_train)}   Test: {len(X_test)}   (80/20 split)")

    pipeline = Pipeline([
        ("tfidf", TfidfVectorizer(
            lowercase=True,
            ngram_range=(1, 2),
            min_df=2,
            sublinear_tf=True,
        )),
        ("clf", LogisticRegression(
            max_iter=1000,
            C=10.0,
            random_state=RANDOM_STATE,
        )),
    ])

    pipeline.fit(X_train, y_train)
    y_pred = pipeline.predict(X_test)

    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average="macro", zero_division=0)
    recall = recall_score(y_test, y_pred, average="macro", zero_division=0)
    f1 = f1_score(y_test, y_pred, average="macro", zero_division=0)

    print("-" * 60)
    print("HELD-OUT TEST METRICS (macro-averaged):")
    print(f"  Accuracy : {accuracy:.4f}")
    print(f"  Precision: {precision:.4f}")
    print(f"  Recall   : {recall:.4f}")
    print(f"  F1-score : {f1:.4f}")
    print("-" * 60)
    print("Per-class report:")
    print(classification_report(y_test, y_pred, zero_division=0))

    os.makedirs(MODEL_DIR, exist_ok=True)
    joblib.dump(pipeline, MODEL_PATH)
    print(f"Saved trained model to {MODEL_PATH}")


if __name__ == "__main__":
    main()
