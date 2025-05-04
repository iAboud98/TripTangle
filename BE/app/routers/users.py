from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import User
from app.schemas import UserRegister, UserLogin, UserOut
from app.utils import hash_password, verify_password, create_access_token

router = APIRouter()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/register", response_model=UserOut)
def register_user(user: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        username=user.username,
        email=user.email,
        password=hash_password(user.password),
        bio=user.bio,
        profile_pic=user.profile_pic,
        current_location=user.current_location  # ✅ Added
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user



@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": db_user.email})
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": UserOut.from_orm(db_user)
    }


@router.get("/{user_id}", response_model=UserOut)
def get_user_by_id(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.get("/search/")
def search_users(query: str, current_user_id: int, db: Session = Depends(get_db)):
    results = db.query(User).filter(
        ((User.username.ilike(f"%{query}%")) | (User.email.ilike(f"%{query}%"))) &
        (User.id != current_user_id)  # ✅ Exclude current user
    ).all()
    return results

