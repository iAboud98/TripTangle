from fastapi import FastAPI
from app.routers import users, Groups, invites
from app.database import Base, engine

from app import models

app = FastAPI()
Base.metadata.create_all(bind=engine)


app.include_router(Groups.router, prefix="/groups", tags=["Groups"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(invites.router, prefix="/invites", tags=["Invites"])