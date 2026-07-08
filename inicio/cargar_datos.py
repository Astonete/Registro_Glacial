import sqlite3
import csv
from pathlib import Path
from configuracion import RUTA_DB,RUTA_CSV,configuracion_pragmas

def crear_instert(tabla,columnas):
    nombre_columnas=", ".join(columnas)
    signos=", ".join(["?"]* len(columnas))
    return f"INSERT INTO {tabla}({nombre_columnas}) VALUES ({signos})"

def preparar_valores(fila):
    valores=[]
    for valor in fila.values():
        if valor == "":
            valores.append(None)
        else:
            valores.append(valor)
    return valores

def insertar_tabla(connection,tabla,ruta_csv):
    ruta_csv=Path(ruta_csv)
    if not ruta_csv.exists():
        print(f"No existe el archivo:{ruta_csv}")
        return

    with open(ruta_csv,"r",encoding="utf-8",newline="")as archivo:
        lector=csv.DictReader(archivo)
        columnas=lector.fieldnames
        sql_insert= crear_instert(tabla,columnas)
        
        insertados=0
        reboto=0
        
        for fila in lector:
            valores=preparar_valores(fila)
            try:
                connection.execute(sql_insert,valores)
                insertados+=1
            except sqlite3.IntegrityError as e:
                reboto+=1
                print(f"fila rechazada (IntegrityError): {valores} -  Motivo: {e}")
            except sqlite3.OperationalError as e:
                print("Error de Operación: ",e)
                print(f"carga detenida {tabla}.")
                break
            except sqlite3.Error as e:
                reboto+=1
                print("Error inesperado",e)
        connection.commit()
    print(f"-> {tabla}: ({insertados} Datos Cargados) | ({reboto} Datos Omitidos)")

def main():
    connection=None
    try:
        connection=sqlite3.connect(RUTA_DB)
        configuracion_pragmas(connection)#Reutiliza la funcion

        for tabla,ruta_csv in RUTA_CSV.items():
            print(f"Procesando {tabla}...")
            insertar_tabla(connection,tabla,ruta_csv)
            
        print("Cargar terminada con éxito.")
        
    except sqlite3.Error as e:
        print("Error: ",e)
    finally:
        if connection:
            connection.close()

if __name__=="__main__":
    main()