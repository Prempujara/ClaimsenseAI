"""
evaluate_model.py
-----------------
Evaluation pipeline for ClaimSense AI Expense Category Classifier.

Evaluates the TF-IDF + Logistic Regression model on a 80/20 stratified
held-out test split of ml/dataset.csv.

Outputs:
  - ml/evaluation/metrics.json
  - ml/evaluation/classification_report.txt
  - ml/evaluation/confusion_matrix.png (if matplotlib is available)

Run:
  py ml/evaluate_model.py
"""

import json
import os
import sys

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (accuracy_score, classification_report,
                             confusion_matrix, f1_score, precision_recall_fscore_support,
                             precision_score, recall_score)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

HERE = os.path.dirname(__file__)
DATASET = os.path.join(HERE, "dataset.csv")
MODEL_PATH = os.path.join(HERE, "model", "expense_classifier.pkl")
EVAL_DIR = os.path.join(HERE, "evaluation")
RANDOM_STATE = 42


def evaluate():
    if not os.path.exists(DATASET):
        print(f"Error: Dataset not found at {DATASET}")
        sys.exit(1)

    df = pd.read_csv(DATASET).dropna(subset=["text", "category"])
    X = df["text"].astype(str)
    y = df["category"].astype(str)

    labels = sorted(y.unique().tolist())

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=RANDOM_STATE, stratify=y
    )

    if os.path.exists(MODEL_PATH):
        model = joblib.load(MODEL_PATH)
    else:
        model = Pipeline([
            ("tfidf", TfidfVectorizer(lowercase=True, ngram_range=(1, 2), min_df=2, sublinear_tf=True)),
            ("clf", LogisticRegression(max_iter=1000, C=10.0, random_state=RANDOM_STATE)),
        ])
        model.fit(X_train, y_train)

    y_pred = model.predict(X_test)

    acc = accuracy_score(y_test, y_pred)
    macro_prec = precision_score(y_test, y_pred, average="macro", zero_division=0)
    macro_rec = recall_score(y_test, y_pred, average="macro", zero_division=0)
    macro_f1 = f1_score(y_test, y_pred, average="macro", zero_division=0)
    weighted_f1 = f1_score(y_test, y_pred, average="weighted", zero_division=0)

    report_text = classification_report(y_test, y_pred, zero_division=0)
    cm = confusion_matrix(y_test, y_pred, labels=labels)

    per_class_p, per_class_r, per_class_f1, per_class_sup = precision_recall_fscore_support(
        y_test, y_pred, labels=labels, zero_division=0
    )

    per_class_metrics = {}
    for i, label in enumerate(labels):
        per_class_metrics[label] = {
            "precision": round(float(per_class_p[i]), 4),
            "recall": round(float(per_class_r[i]), 4),
            "f1_score": round(float(per_class_f1[i]), 4),
            "support": int(per_class_sup[i])
        }

    os.makedirs(EVAL_DIR, exist_ok=True)

    metrics_json = {
        "dataset_total": len(df),
        "train_samples": len(X_train),
        "test_samples": len(X_test),
        "categories_count": len(labels),
        "metrics": {
            "accuracy": round(float(acc), 4),
            "macro_precision": round(float(macro_prec), 4),
            "macro_recall": round(float(macro_rec), 4),
            "macro_f1": round(float(macro_f1), 4),
            "weighted_f1": round(float(weighted_f1), 4)
        },
        "per_class": per_class_metrics,
        "confusion_matrix": cm.tolist(),
        "labels": labels
    }

    with open(os.path.join(EVAL_DIR, "metrics.json"), "w", encoding="utf-8") as f:
        json.dump(metrics_json, f, indent=2)

    with open(os.path.join(EVAL_DIR, "classification_report.txt"), "w", encoding="utf-8") as f:
        f.write(f"ClaimSense AI ML Model Evaluation Report\n")
        f.write(f"========================================\n")
        f.write(f"Train samples : {len(X_train)}\n")
        f.write(f"Test samples  : {len(X_test)}\n")
        f.write(f"Accuracy      : {acc:.4f}\n")
        f.write(f"Macro F1      : {macro_f1:.4f}\n")
        f.write(f"Weighted F1   : {weighted_f1:.4f}\n\n")
        f.write("Per-category Report:\n")
        f.write(report_text)

    # Plot confusion matrix if matplotlib is installed
    try:
        import matplotlib.pyplot as plt

        plt.figure(figsize=(8, 6))
        plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
        plt.title('Expense Classifier Confusion Matrix')
        plt.colorbar()
        tick_marks = list(range(len(labels)))
        plt.xticks(tick_marks, labels, rotation=45, ha='right')
        plt.yticks(tick_marks, labels)
        plt.tight_layout()
        plt.ylabel('True Label')
        plt.xlabel('Predicted Label')
        plt.savefig(os.path.join(EVAL_DIR, "confusion_matrix.png"), dpi=150)
        plt.close()
        print("Generated confusion_matrix.png visual plot.")
    except Exception as e:
        print(f"Plotting skipped ({e}). Metrics JSON & text report saved.")

    print("==================================================")
    print("      ClaimSense AI ML Model Evaluation Result    ")
    print("==================================================")
    print(f"Total dataset samples : {len(df)}")
    print(f"Train samples         : {len(X_train)}")
    print(f"Test samples          : {len(X_test)}")
    print(f"Accuracy              : {acc:.4f}")
    print(f"Macro Precision       : {macro_prec:.4f}")
    print(f"Macro Recall          : {macro_rec:.4f}")
    print(f"Macro F1-score        : {macro_f1:.4f}")
    print(f"Weighted F1-score     : {weighted_f1:.4f}")
    print("==================================================")
    print("Saved evaluation artifacts to ml/evaluation/")
    return metrics_json


if __name__ == "__main__":
    evaluate()
