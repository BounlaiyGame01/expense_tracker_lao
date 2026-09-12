from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models
from .database import engine, SessionLocal
from .routers import categories, transactions, budgets

# Creates tables in MySQL automatically if they don't exist yet.
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Expense Tracker Lao API")

# Allows the Flutter app (emulator, phone, web) to call this API from any origin.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(categories.router)
app.include_router(transactions.router)
app.include_router(budgets.router)

DEFAULT_CATEGORIES = [
    ("Food", "food", 0xFFE57373, "expense"),
    ("Transport", "transport", 0xFF64B5F6, "expense"),
    ("Education", "education", 0xFF9575CD, "expense"),
    ("Shopping", "shopping", 0xFFFFB74D, "expense"),
    ("Entertainment", "entertainment", 0xFF4DB6AC, "expense"),
    ("Bills", "bills", 0xFF90A4AE, "expense"),
    ("Health", "health", 0xFFF06292, "expense"),
    ("Other", "other", 0xFFA1887F, "expense"),
    ("Salary/Allowance", "salary", 0xFF388E3C, "income"),
    ("Gift", "gift", 0xFF7CB342, "income"),
    ("Part-time job", "parttime", 0xFF00897B, "income"),
]


@app.on_event("startup")
def seed_default_categories():
    """Runs once at server startup; only inserts defaults if the table is empty."""
    db = SessionLocal()
    try:
        if db.query(models.Category).count() == 0:
            for name, icon_name, color_value, ctype in DEFAULT_CATEGORIES:
                db.add(models.Category(
                    name=name, icon_name=icon_name, color_value=color_value, type=ctype
                ))
            db.commit()
    finally:
        db.close()


@app.get("/")
def root():
    return {"status": "ok", "service": "expense-tracker-lao-api"}
