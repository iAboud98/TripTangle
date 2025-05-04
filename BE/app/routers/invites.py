from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import GroupInvite, GroupMember
from app.schemas import InviteCreate, InviteOut, PreferencesIn

router = APIRouter(prefix="/invites", tags=["Invites"])


@router.post("/send", response_model=InviteOut)
def send_invite(invite: InviteCreate, db: Session = Depends(get_db)):
    existing = db.query(GroupInvite).filter_by(
        group_id=invite.group_id,
        invited_user_id=invite.invited_user_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already invited.")

    new_invite = GroupInvite(**invite.dict())
    db.add(new_invite)
    db.commit()
    db.refresh(new_invite)
    return new_invite


@router.get("/me/{user_id}", response_model=list[InviteOut])
def get_my_invites(user_id: int, db: Session = Depends(get_db)):
    invites = db.query(GroupInvite).filter_by(
        invited_user_id=user_id,
        accepted=False
    ).all()
    return invites


@router.post("/accept/{invite_id}")
def accept_invite(invite_id: int, preferences: PreferencesIn, db: Session = Depends(get_db)):
    invite = db.query(GroupInvite).filter_by(id=invite_id).first()
    if not invite:
        raise HTTPException(status_code=404, detail="Invite not found")

    if invite.accepted:
        raise HTTPException(status_code=400, detail="Invite already accepted")

    # Mark invite as accepted
    invite.accepted = True
    db.commit()

    # Add user to group members with preferences
    new_member = GroupMember(
        group_id=invite.group_id,
        user_id=invite.invited_user_id,
        preferences=preferences.dict()
    )
    db.add(new_member)
    db.commit()

    return {"msg": "Invite accepted, preferences saved, and user added to group."}


@router.delete("/{invite_id}")
def decline_invite(invite_id: int, db: Session = Depends(get_db)):
    invite = db.query(GroupInvite).filter_by(id=invite_id).first()
    if not invite:
        raise HTTPException(status_code=404, detail="Invite not found")

    db.delete(invite)
    db.commit()
    return {"msg": "Invite declined/deleted."}
