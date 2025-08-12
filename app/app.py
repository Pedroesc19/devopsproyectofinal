import os
from flask import Flask, jsonify, request, render_template
from sqlalchemy import create_engine, text

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USERNAME", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "root")
DB_NAME = os.getenv("DB_NAME", "appdb")

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

def create_app():
    app = Flask(__name__)

    engine = create_engine(DATABASE_URL, pool_pre_ping=True)

    # bootstrap de tabla de inventario
    with engine.begin() as conn:
        conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                quantity INT NOT NULL DEFAULT 0
            ) ENGINE=InnoDB;
            """
        ))

    @app.get("/")
    def index():
        return render_template("index.html")

    @app.get("/healthz")
    def healthz():
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return jsonify({"db": "up"}), 200
        except Exception as e:
            return jsonify({"db": "down", "error": str(e)}), 500

    @app.get("/items")
    def list_items():
        with engine.connect() as conn:
            rows = conn.execute(text("SELECT id, name, quantity FROM items ORDER BY id"))
            return jsonify([
                {"id": r.id, "name": r.name, "quantity": r.quantity}
                for r in rows
            ])

    @app.post("/items")
    def create_item():
        data = request.get_json(silent=True) or {}
        name = data.get("name")
        quantity = data.get("quantity", 0)
        if not name:
            return jsonify({"error": "name is required"}), 400
        with engine.begin() as conn:
            conn.execute(
                text("INSERT INTO items(name, quantity) VALUES (:n, :q)"),
                {"n": name, "q": quantity},
            )
        return jsonify({"ok": True}), 201

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=8080)
