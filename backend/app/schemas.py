from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, ConfigDict


class CategoryTypeSchema(str, Enum):
    income = "income"
    expense = "expense"


# ---------------- Category ----------------
class CategoryCreate(BaseModel):
    name: str
    icon_name: str
    color_value: int
    type: CategoryTypeSchema


class CategoryOut(CategoryCreate):
    id: int
    model_config = ConfigDict(from_attributes=True)


# ---------------- Transaction ----------------
class TransactionCreate(BaseModel):
    type: CategoryTypeSchema
    amount: float
    category_id: int
    date: datetime
    note: Optional[str] = ""


class TransactionOut(TransactionCreate):
    id: int
    model_config = ConfigDict(from_attributes=True)


# ---------------- Budget ----------------
class BudgetCreate(BaseModel):
    category_id: int
    month: int
    year: int
    amount: float


class BudgetOut(BudgetCreate):
    id: int
    model_config = ConfigDict(from_attributes=True)
