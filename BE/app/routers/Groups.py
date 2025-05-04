from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Group, GroupMember, User, GroupSuggestion
from app.schemas import GroupCreate, GroupOut, GroupJoin
from typing import List
from datetime import datetime

from app.utils import aggregate_preferences, suggest_destinations_with_gemini

router = APIRouter(
    prefix="/groups",
    tags=["Groups"]
)

@router.post("/", response_model=GroupOut)
def create_group(group: GroupCreate, db: Session = Depends(get_db)):
    new_group = Group(
        name=group.name,
        created_by=group.created_by,
        group_photo=group.group_photo,
        is_public=group.is_public,
        created_date=datetime.utcnow()
    )
    db.add(new_group)
    db.commit()
    db.refresh(new_group)
    return new_group


@router.get("/{group_id}", response_model=GroupOut)
def get_group(group_id: int, db: Session = Depends(get_db)):
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")
    return group


from fastapi import Query

@router.get("/", response_model=List[GroupOut])
def list_user_groups(user_id: int = Query(...), db: Session = Depends(get_db)):
    # Groups created by user
    created_groups = db.query(Group).filter(Group.created_by == user_id)

    # Groups where user is a member
    member_group_ids = db.query(GroupMember.group_id).filter(GroupMember.user_id == user_id).subquery()
    member_groups = db.query(Group).filter(Group.id.in_(member_group_ids))

    # Union results
    all_groups = created_groups.union(member_groups).all()
    return all_groups



@router.post("/join/{group_id}")
def join_group(group_id: int, member_data: GroupJoin, db: Session = Depends(get_db)):
    # Check group exists
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    new_member = GroupMember(
        group_id=group_id,
        user_id=member_data.user_id,
        preferences=member_data.preferences
    )
    db.add(new_member)
    db.commit()
    return {"message": "Joined group successfully"}




@router.get("/{group_id}/analyze")
def analyze_group_preferences(group_id: int, db: Session = Depends(get_db)):
    members = db.query(GroupMember).filter_by(group_id=group_id).all()
    if not members:
        raise HTTPException(status_code=404, detail="No members in group.")

    preferences_list = [m.preferences for m in members if m.preferences]
    if not preferences_list:
        raise HTTPException(status_code=400, detail="Members haven't filled preferences.")

    aggregated = aggregate_preferences(preferences_list)

    # Get destinations from Gemini
    suggestions = suggest_destinations_with_gemini(aggregated)

    # Add vote tracking to each suggestion
    for s in suggestions:
        s["votes"] = {
            "number": 0,
            "by": []  # later will contain { id, name, profile_pic }
        }

    # Remove existing suggestions for this group (optional: depends on your logic)
    db.query(GroupSuggestion).filter_by(group_id=group_id).delete()

    # Save the new suggestion record
    new_suggestion = GroupSuggestion(group_id=group_id, suggestions_json=suggestions)
    db.add(new_suggestion)
    db.commit()

    return {
        "group_id": group_id,
        "aggregated_preferences": aggregated,
        "suggested_destinations": suggestions
    }



#
# @router.post("/groups/{group_id}/vote")
# def vote_suggestion(group_id: int, suggestion_city: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
#     record = db.query(GroupSuggestion).filter_by(group_id=group_id).first()
#     if not record:
#         raise HTTPException(404, "No suggestions found.")
#
#     updated = False
#     for suggestion in record.suggestions_json:
#         if suggestion["city"].lower() == suggestion_city.lower():
#             # Prevent double voting
#             if any(voter["id"] == user.id for voter in suggestion["votes"]["by"]):
#                 raise HTTPException(400, "User already voted.")
#             suggestion["votes"]["number"] += 1
#             suggestion["votes"]["by"].append({
#                 "id": user.id,
#                 "name": user.name,
#                 "profile_pic": user.profile_pic
#             })
#             updated = True
#             break
#
#     if not updated:
#         raise HTTPException(404, "Suggestion not found.")
#
#     db.commit()
#     return {"message": "Vote registered successfully."}
#
