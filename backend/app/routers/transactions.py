from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.get("", response_model=List[schemas.TransactionOut])
def list_transactions(
    year: Optional[int] = None,
    month: Optional[int] = None,
    db: Session = Depends(get_db),
):
    q = db.query(models.Transaction)
    if year and month:
        start = datetime(year, month, 1)
        end = datetime(year + 1, 1, 1) if month == 12 else datetime(year, month + 1, 1)
        q = q.filter(models.Transaction.date >= start, models.Transaction.date < end)
    return q.order_by(models.Transaction.date.desc()).all()


@router.post("", response_model=schemas.TransactionOut)
def create_transaction(payload: schemas.TransactionCreate, db: Session = Depends(get_db)):
    obj = models.Transaction(**payload.model_dump())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


@router.put("/{tx_id}", response_model=schemas.TransactionOut)
def update_transaction(tx_id: int, payload: schemas.TransactionCreate, db: Session = Depends(get_db)):
    obj = db.get(models.Transaction, tx_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Transaction not found")
    for key, value in payload.model_dump().items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj


@router.delete("/{tx_id}")
def delete_transaction(tx_id: int, db: Session = Depends(get_db)):
    obj = db.get(models.Transaction, tx_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Transaction not found")
    db.delete(obj)
    db.commit()
    return {"ok": True}
