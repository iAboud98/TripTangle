from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, JSON, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

# =======================
# USERS TABLE
# =======================
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, nullable=False, unique=True)
    email = Column(String, nullable=False, unique=True)
    password = Column(String, nullable=False)
    bio = Column(Text)
    profile_pic = Column(String)  # URL or file path
    current_location = Column(String)

    groups = relationship("GroupMember", back_populates="user")


# =======================
# GROUPS TABLE
# =======================
class Group(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    created_by = Column(Integer, ForeignKey("users.id"))
    created_date = Column(DateTime(timezone=True), server_default=func.now())
    group_photo = Column(String)  # emoji or URL
    is_public = Column(Boolean, default=False)

    members = relationship("GroupMember", back_populates="group")
    suggestions = relationship("GroupSuggestion", back_populates="group")


# =======================
# GROUP MEMBERS (JOIN TABLE)
# =======================
class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    preferences = Column(JSON)  # interests, period, weather, budget, etc.

    group = relationship("Group", back_populates="members")
    user = relationship("User", back_populates="groups")


# =======================
# GROUP SUGGESTIONS & VOTES
# =======================
class GroupSuggestion(Base):
    __tablename__ = "group_suggestions"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.id"))
    suggestions_json = Column(JSON)  # List of suggestions with votes

    group = relationship("Group", back_populates="suggestions")


# =======================
# GROUP Invites
# =======================
class GroupInvite(Base):
    __tablename__ = "group_invites"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.id"), nullable=False)
    invited_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    invited_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    accepted = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())