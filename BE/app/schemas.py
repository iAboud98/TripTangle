from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime



class UserRegister(BaseModel):
    username: str
    email: EmailStr
    password: str
    bio: Optional[str] = None
    profile_pic: Optional[str] = None
    current_location: Optional[str] = None  # ✅ New field

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    username: str
    email: EmailStr
    bio: Optional[str]
    profile_pic: Optional[str]
    current_location: Optional[str] = None  # ✅ New field

    class Config:
        from_attributes = True  # ✅ Correct for Pydantic v2





# -----------------------
# Base Group Schema
# -----------------------
class GroupBase(BaseModel):
    name: str
    created_by: int
    group_photo: Optional[str] = None  # emoji or image URL
    is_public: Optional[bool] = False


# -----------------------
# Create Group Request
# -----------------------
class GroupCreate(GroupBase):
    pass


# -----------------------
# Group Output Schema
# -----------------------
class GroupOut(GroupBase):
    id: int
    created_date: datetime

    class Config:
        from_attributes = True


# -----------------------
# Group Join Schema
# -----------------------
class GroupJoin(BaseModel):
    user_id: int
    preferences: dict  # includes budget, interests, weather, etc.

class InviteCreate(BaseModel):
        group_id: int
        invited_user_id: int
        invited_by_user_id: int

class InviteOut(BaseModel):
        id: int
        group_id: int
        invited_user_id: int
        invited_by_user_id: int
        accepted: bool
        created_at: datetime

        class Config:
            from_attributes = True

class PreferencesIn(BaseModel):
    interests: Optional[list[str]] = []
    period: Optional[str] = None
    weather: Optional[str] = None
    budget: Optional[str] = None

    class Config:
        from_attributes = True  # for compatibility with from_orm if needed

