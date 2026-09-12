from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get("", response_model=List[schemas.CategoryOut])
def list_categories(type: Optional[schemas.CategoryTypeSchema] = None, db: Session = Depends(get_db)):
    q = db.query(models.Category)
    if type:
        q = q.filter(models.Category.type == type)
    return q.order_by(models.Category.name).all()


@router.post("", response_model=schemas.CategoryOut)
def create_category(payload: schemas.CategoryCreate, db: Session = Depends(get_db)):
    obj = models.Category(**payload.model_dump())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


@router.put("/{category_id}", response_model=schemas.CategoryOut)
def update_category(category_id: int, payload: schemas.CategoryCreate, db: Session = Depends(get_db)):
    obj = db.get(models.Category, category_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Category not found")
    for key, value in payload.model_dump().items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj


@router.delete("/{category_id}")
def delete_category(category_id: int, db: Session = Depends(get_db)):
    obj = db.get(models.Category, category_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Category not found")
    db.delete(obj)
    db.commit()
    return {"ok": True}
