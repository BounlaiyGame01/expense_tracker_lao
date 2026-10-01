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



@app.on_event("startup")
def seed_default_categories():
    """Runs once at server startup; only inserts defaults if the table is empty."""
    db = SessionLocal()
    try:
        if db.query(models.Category).count() == 0:
            for name, icon_name, color_value, ctype in [
                ("Salary", "attach_money", 0xFF4CAF50, models.CategoryType.income),
                ("Business", "business_center", 0xFF4CAF50, models.CategoryType.income),
                ("Food", "restaurant", 0xFFF44336, models.CategoryType.expense),
                ("Transport", "directions_car", 0xFF2196F3, models.CategoryType.expense),
                ("Shopping", "shopping_cart", 0xFFFFC107, models.CategoryType.expense),
                ("Entertainment", "movie", 0xFF9C27B0, models.CategoryType.expense),
                ("Health", "local_hospital", 0xFFE91E63, models.CategoryType.expense),
                ("Education", "school", 0xFF3F51B5, models.CategoryType.expense),
                ("Travel", "flight_takeoff", 0xFFFF5722, models.CategoryType.expense),
                ("Utilities", "flash_on", 0xFF00BCD4, models.CategoryType.expense),
                ("Others", "more_horiz", 0xFF9E9E9E, models.CategoryType.expense),
            ]:
                db.add(models.Category(
                    name=name, icon_name=icon_name, color_value=color_value, type=ctype
                ))
            db.commit()
    finally:
        db.close()


@app.get("/")
def root():
    return {"status": "ok", "service": "expense-tracker-lao-api"}
