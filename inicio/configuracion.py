from pathlib import Path
from typing import Dict
import sqlite3

# Directorio raíz del Proyecto(Donde esta archvo)
BASE_DIR=Path(__file__).resolve().parent.parent# subimos un nivel

RUTA_DB=BASE_DIR/"base_de_datos"/"base_datos.db"
RUTA_ESQUEMA=BASE_DIR/"base_de_datos"/"esquema.sql"
#RUTA_RESET=BASE_DIR/"base_de_datos"/"reset_esquema.sql"
RUTA_CONSULTA=BASE_DIR/"base_de_datos"/"consulta.sql"


# Directorio con nombres -> ruta de cada archivo csv
RUTA_CSV: Dict[str,Path]={
    # 1 Nivel entidad no dependen de otro
    "customers": BASE_DIR / "data"/ "customers.csv",
    "products": BASE_DIR / "data"/ "products.csv",
    # 2 Nivel depende de cliente "customers"
    "orders": BASE_DIR / "data"/ "orders.csv",
    "payments": BASE_DIR / "data"/ "payments.csv",
    # 3 Nivel dependen de orders (y orders depende de customers/products)
    "order_items": BASE_DIR / "data"/ "order_items.csv",
    "order_status_history": BASE_DIR / "data"/ "order_status_history.csv",
    "order_audit": BASE_DIR / "data"/ "order_audit.csv",
}

def verificar_estructura()-> None:
    # verificar que exista los directorio y archivos necesarios si falta fileNotFoundError
    #crea el directorio data si no existe
    (BASE_DIR/"data").mkdir(parents=True,exist_ok=True)
    (BASE_DIR/"base_de_datos").mkdir(parents=True,exist_ok=True)

    #verifica cada archivo CSV
    for nombre, ruta in RUTA_CSV.items():
        if not ruta.exists():
            raise FileNotFoundError (f"el Archivo {nombre} no se encuentra en {ruta}")

    #Verifica que el esquema SQL existe    
    if not RUTA_ESQUEMA.exists():
        raise FileNotFoundError(f"El esquema SQL no se encuentra en {RUTA_ESQUEMA}")
    #asegura que el directorio de la base de datos existe

def configuracion_pragmas(conn:sqlite3.Connection)->None:
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.execute("PRAGMA journal_mode = WAL;")
