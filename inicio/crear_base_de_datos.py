import sqlite3
from pathlib import Path
from configuracion import RUTA_BD, RUTA_ESQUEMA, verificar_estructura, configuracion_pragmas

def crear_tablas(conn:sqlite3.Connection,schema_path:Path)->None:
    #"Ejecuta el script de sql del esquema"
    with open(schema_path,"r",encoding="utf-8")as archivo:
        sql=archivo.read()
    conn.executescript(sql)

def incializar_base_de_datos()->None:
    #verifica estructura, conecta y crea tablas
    try:
        verificar_estructura()
        print("✅ Estructura de archivos verificado correctamente...")
    except FileNotFoundError as e:
        print(f"❌ Error en la estructura de archivos: {e}")
        raise
    
    try:
        with sqlite3.connect(RUTA_BD)as conn:
            configuracion_pragmas(conn)
            crear_tablas(conn,RUTA_ESQUEMA)
            print("✅ Base de datos inicializada correctamente.")
    except sqlite3.Error as e:
        print(f"Error de SQLite al crear la base de datos: {e}")
        raise

def main()->None:
    incializar_base_de_datos()

if __name__=="__main__":
    main()