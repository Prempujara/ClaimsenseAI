"""
generate_dataset.py
--------------------
Builds a labelled training set for the expense-category classifier.

Each row is a short piece of free text (merchant name + a natural description,
the same kind of text the running app feeds the /predict endpoint) paired with
one of the seven categories seeded in the database:

    Food, Travel, Accommodation, Office Supplies, Entertainment, Medical, Other

The generator is fully deterministic (fixed RNG seed) so the dataset - and
therefore the trained model and its reported metrics - is reproducible.

Run:
    python generate_dataset.py
Output:
    dataset.csv   (columns: text,category)
"""

import csv
import os
import random

SEED = 42
ROWS_PER_CATEGORY = 170          # base rows per category
AMBIGUOUS_ROWS_EACH = 10         # per (shared-merchant, category) pair
GENERIC_ROWS_EACH = 18           # per category, low-signal descriptions
OUT_PATH = os.path.join(os.path.dirname(__file__), "dataset.csv")

# Merchants / vendors typical of each category (Indian-context, matches the UI).
MERCHANTS = {
    "Food": [
        "Starbucks", "Cafe Coffee Day", "Dominos Pizza", "McDonalds", "KFC",
        "Zomato", "Swiggy", "Barbeque Nation", "Subway", "Haldirams",
        "Chai Point", "Burger King", "Pizza Hut", "Faasos", "Biryani Blues",
        "Third Wave Coffee", "Theobroma", "Wow Momo",
    ],
    "Travel": [
        "Uber", "Ola Cabs", "IndiGo Airlines", "Air India", "IRCTC",
        "Rapido", "Meru Cabs", "Vistara", "SpiceJet", "HP Petrol Pump",
        "Indian Oil", "FASTag Toll", "RedBus", "Ola Auto", "Bharat Petroleum",
        "Blablacar", "MakeMyTrip Flights",
    ],
    "Accommodation": [
        "OYO Rooms", "Taj Hotels", "Marriott", "Airbnb", "Treebo Hotels",
        "FabHotels", "The Leela", "Radisson Blu", "Lemon Tree Hotel",
        "ITC Hotels", "Ginger Hotel", "Novotel", "Zostel", "Guest House Stay",
        "Holiday Inn",
    ],
    "Office Supplies": [
        "Amazon Business", "Staples", "Office Depot", "Flipkart Wholesale",
        "WH Smith", "Reliance Digital", "Croma", "Pen Store", "Paper Plus",
        "HP Store", "Canon Store", "Stationery Mart", "Bic Supplies",
        "Whitebook Stationers",
    ],
    "Entertainment": [
        "BookMyShow", "PVR Cinemas", "INOX", "Netflix", "Spotify",
        "Amazon Prime", "Disney Hotstar", "Wonderla", "Smaaash",
        "Game Zone Arcade", "Comedy Club", "Concert Tickets", "Bowling Alley",
        "Cinepolis",
    ],
    "Medical": [
        "Apollo Pharmacy", "Netmeds", "1mg", "MedPlus", "Fortis Hospital",
        "Practo Clinic", "Max Healthcare", "Dr Lal PathLabs", "Metropolis Labs",
        "Wellness Forever", "Manipal Hospital", "PharmEasy", "Cloudnine Clinic",
        "Health Checkup Centre",
    ],
    "Other": [
        "Blue Dart Courier", "India Post", "DTDC", "Amazon Gift Card",
        "Bank Service Charge", "Xerox Shop", "Locksmith Service",
        "Laundry Express", "Gift Shop", "Donation Trust", "Membership Renewal",
        "Repair Services", "FedEx", "Miscellaneous Vendor",
    ],
}

# Natural-language description templates per category ({m} = merchant).
TEMPLATES = {
    "Food": [
        "Business lunch at {m} with client",
        "Team dinner bill from {m}",
        "Coffee meeting at {m}",
        "Snacks and beverages from {m}",
        "Working lunch ordered via {m}",
        "Breakfast at {m} during offsite",
        "Client hospitality meal at {m}",
        "Ordered dinner from {m} for the team",
        "Cafeteria refreshments {m}",
        "Food order {m} for review meeting",
    ],
    "Travel": [
        "Cab ride to office booked on {m}",
        "Airport transfer with {m}",
        "Flight ticket booked through {m}",
        "Train reservation via {m}",
        "Fuel refill at {m}",
        "Toll charges paid at {m}",
        "Taxi fare {m} for client visit",
        "Intercity travel booked on {m}",
        "Commute to client site using {m}",
        "Cab receipt {m} for late night travel",
    ],
    "Accommodation": [
        "Hotel stay at {m} for conference",
        "Room booking at {m} during business trip",
        "Two night stay at {m}",
        "Lodging expense {m} for offsite",
        "Accommodation booked at {m}",
        "Hotel invoice from {m}",
        "Overnight stay {m} near client office",
        "Business trip lodging {m}",
        "Checked in at {m} for training",
        "Guest house booking {m}",
    ],
    "Office Supplies": [
        "Purchased printer cartridges from {m}",
        "Stationery order from {m}",
        "Bought notebooks and pens at {m}",
        "Office paper and files from {m}",
        "New keyboard and mouse from {m}",
        "Desk organizer purchase {m}",
        "Whiteboard markers from {m}",
        "Toner refill {m}",
        "Office supplies restock {m}",
        "Bought a monitor stand from {m}",
    ],
    "Entertainment": [
        "Team outing movie tickets on {m}",
        "Subscription renewal for {m}",
        "Booked show tickets via {m}",
        "Team building activity at {m}",
        "Movie night booked on {m}",
        "Recreation event tickets {m}",
        "Concert passes from {m}",
        "Arcade games at {m} team event",
        "Streaming subscription {m}",
        "Entertainment expense {m} for offsite",
    ],
    "Medical": [
        "Purchased medicines from {m}",
        "Pharmacy bill at {m}",
        "Doctor consultation at {m}",
        "Lab tests done at {m}",
        "Health checkup at {m}",
        "Bought prescription drugs from {m}",
        "Medical reimbursement {m}",
        "First aid supplies from {m}",
        "Diagnostic test invoice {m}",
        "Clinic visit charges {m}",
    ],
    "Other": [
        "Courier charges paid to {m}",
        "Document shipment via {m}",
        "Bank charges from {m}",
        "Miscellaneous purchase at {m}",
        "Gift for client from {m}",
        "Photocopy and printing at {m}",
        "Laundry service {m} during travel",
        "Annual membership fee {m}",
        "Repair service payment {m}",
        "Postage and mailing {m}",
    ],
}

# Vendors that genuinely sell across categories. The SAME merchant string maps
# to different labels depending on the wording, so the model must learn from
# the description, not just memorise the vendor. This is the main driver of
# realistic (sub-100%) accuracy.
AMBIGUOUS = {
    "Amazon": {
        "Office Supplies": ["order of A4 paper and printer ink",
                            "purchased a wireless keyboard",
                            "bought desk organiser and files"],
        "Entertainment": ["Prime Video subscription renewal",
                          "annual Prime membership for streaming",
                          "movie rental on Prime Video"],
        "Other": ["gift card purchase for client",
                  "miscellaneous household order",
                  "gift voucher for team reward"],
    },
    "Reliance": {
        "Food": ["Reliance Fresh groceries and snacks",
                 "Reliance Smart food supplies",
                 "grocery bill at Reliance Fresh"],
        "Office Supplies": ["Reliance Digital printer purchase",
                            "Reliance Digital pen drive and cables",
                            "office electronics at Reliance Digital"],
        "Entertainment": ["Reliance Trends movie combo tickets",
                          "BigCinemas ticket via Reliance",
                          "gaming console from Reliance Digital"],
    },
    "Big Bazaar": {
        "Food": ["grocery and food items from Big Bazaar",
                 "snacks and beverages at Big Bazaar",
                 "monthly food supplies Big Bazaar"],
        "Office Supplies": ["stationery and files from Big Bazaar",
                            "notebooks and pens at Big Bazaar",
                            "office consumables Big Bazaar"],
        "Other": ["assorted household items Big Bazaar",
                  "miscellaneous purchase at Big Bazaar",
                  "general store bill Big Bazaar"],
    },
    "Walmart": {
        "Food": ["groceries and pantry items from Walmart",
                 "food and drinks bought at Walmart"],
        "Office Supplies": ["printer paper and folders from Walmart",
                            "office stationery from Walmart"],
        "Medical": ["over the counter medicines from Walmart pharmacy",
                    "first aid supplies from Walmart"],
    },
}

# Short, low-signal descriptions with no strong merchant cue - the kind of
# terse note employees actually type. Deliberately fuzzy so a few get confused.
GENERIC = {
    "Food": ["team lunch reimbursement", "meal expense", "refreshments for meeting"],
    "Travel": ["local travel reimbursement", "cab fare", "conveyance charges"],
    "Accommodation": ["stay reimbursement", "lodging charges", "hotel expense"],
    "Office Supplies": ["office supplies", "stationery reimbursement",
                        "printer consumables"],
    "Entertainment": ["team recreation expense", "subscription charge",
                      "event tickets"],
    "Medical": ["medical reimbursement", "pharmacy expense", "clinic charges"],
    "Other": ["miscellaneous reimbursement", "general expense",
              "sundry charges"],
}


def build_rows():
    rng = random.Random(SEED)
    rows = []
    for category, merchants in MERCHANTS.items():
        templates = TEMPLATES[category]
        for _ in range(ROWS_PER_CATEGORY):
            merchant = rng.choice(merchants)
            template = rng.choice(templates)
            desc = template.format(m=merchant)
            # Combine merchant + description the way the app builds predict text.
            text = f"{merchant} {desc}"
            rows.append((text, category))

    # ---- inject realistic ambiguity ----
    # Real receipts are not perfectly separable: some vendors legitimately sell
    # across categories (Amazon -> office supplies / entertainment / gift cards)
    # and some descriptions are generic. Without this, a merchant->category
    # lookup scores a trivial 100%, which would misrepresent the model. These
    # rows force the classifier to generalise from language, producing honest,
    # non-perfect precision/recall/F1.
    for merchant, options in AMBIGUOUS.items():
        for category, phrases in options.items():
            for _ in range(AMBIGUOUS_ROWS_EACH):
                phrase = rng.choice(phrases)
                text = f"{merchant} {phrase}"
                rows.append((text, category))

    # Generic, low-signal descriptions that only weakly hint at a category.
    for category, phrases in GENERIC.items():
        for _ in range(GENERIC_ROWS_EACH):
            phrase = rng.choice(phrases)
            rows.append((phrase, category))

    # Deduplicate on text. Exact-duplicate rows split across the train/test
    # boundary let the model *memorise* strings and inflate the held-out score
    # to a misleading 100%. Keeping only unique texts means every test example
    # is genuinely unseen, so the reported metrics measure real generalisation.
    seen = set()
    unique = []
    for text, category in rows:
        if text in seen:
            continue
        seen.add(text)
        unique.append((text, category))

    rng.shuffle(unique)
    return unique


def main():
    rows = build_rows()
    with open(OUT_PATH, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["text", "category"])
        writer.writerows(rows)
    print(f"Wrote {len(rows)} rows to {OUT_PATH}")


if __name__ == "__main__":
    main()
