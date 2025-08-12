import os
from flask import Flask, jsonify, request
from sqlalchemy import create_engine, text

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USERNAME", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "root")
DB_NAME = os.getenv("DB_NAME", "appdb")

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

def create_app():
    app = Flask(__name__)

    engine = create_engine(DATABASE_URL, pool_pre_ping=True)

    # bootstrap de tabla simple
    with engine.begin() as conn:
        conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL
            ) ENGINE=InnoDB;
            """
        ))

    @app.get("/")
    def index():
        return jsonify({"status": "ok", "service": "flask-ecs"})

    @app.get("/healthz")
    def healthz():
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return jsonify({"db": "up"}), 200
        except Exception as e:
            return jsonify({"db": "down", "error": str(e)}), 500

    @app.get("/users")
    def list_users():
        with engine.connect() as conn:
            rows = conn.execute(text("SELECT id, name FROM users ORDER BY id"))
            return jsonify([{"id": r.id, "name": r.name} for r in rows])

    @app.post("/users")
    def create_user():
        data = request.get_json(silent=True) or {}
        name = data.get("name")
        if not name:
            return jsonify({"error": "name is required"}), 400
        with engine.begin() as conn:
            conn.execute(text("INSERT INTO users(name) VALUES (:n)"), {"n": name})
        return jsonify({"ok": True}), 201

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=8080)