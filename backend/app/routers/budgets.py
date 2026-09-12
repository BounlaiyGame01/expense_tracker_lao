from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/budgets", tags=["budgets"])


@router.get("", response_model=List[schemas.BudgetOut])
def list_budgets(year: Optional[int] = None, month: Optional[int] = None, db: Session = Depends(get_db)):
    q = db.query(models.Budget)
    if year and month:
        q = q.filter(models.Budget.year == year, models.Budget.month == month)
    return q.all()


@router.post("", response_model=schemas.BudgetOut)
def create_budget(payload: schemas.BudgetCreate, db: Session = Depends(get_db)):
    obj = models.Budget(**payload.model_dump())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


@router.put("/{budget_id}", response_model=schemas.BudgetOut)
def update_budget(budget_id: int, payload: schemas.BudgetCreate, db: Session = Depends(get_db)):
    obj = db.get(models.Budget, budget_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Budget not found")
    for key, value in payload.model_dump().items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj


@router.delete("/{budget_id}")
def delete_budget(budget_id: int, db: Session = Depends(get_db)):
    obj = db.get(models.Budget, budget_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Budget not found")
    db.delete(obj)
    db.commit()
    return {"ok": True}
