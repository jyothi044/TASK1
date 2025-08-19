from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, engine
from models import Base
from schemas import Todo, TodoCreate
from crud import get_todos, get_todo, create_todo, update_todo, delete_todo

Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/todos/", response_model=list[Todo])
def read_todos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return get_todos(db, skip, limit)

@app.get("/todos/{todo_id}", response_model=Todo)
def read_todo(todo_id: int, db: Session = Depends(get_db)):
    todo = get_todo(db, todo_id)
    if todo is None:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo

@app.post("/todos/", response_model=Todo)
def create(todo: TodoCreate, db: Session = Depends(get_db)):
    return create_todo(db, todo)

@app.put("/todos/{todo_id}", response_model=Todo)
def update(todo_id: int, todo: TodoCreate, db: Session = Depends(get_db)):
    updated_todo = update_todo(db, todo_id, todo)
    if updated_todo is None:
        raise HTTPException(status_code=404, detail="Todo not found")
    return updated_todo

@app.delete("/todos/{todo_id}")
def delete(todo_id: int, db: Session = Depends(get_db)):
    deleted_todo = delete_todo(db, todo_id)
    if deleted_todo is None:
        raise HTTPException(status_code=404, detail="Todo not found")
    return {"message": "Todo deleted"}