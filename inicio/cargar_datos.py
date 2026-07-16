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

    if not Path(ruta_csv).exists():
        print(f"No existe el archivo:{ruta_csv}")
        return {"Tabla": tabla, "insertados": 0, "reboto": 0, "revertido": 0, "error_critico": False}

    with open(ruta_csv,"r",encoding="utf-8",newline="")as archivo:
        lector=csv.DictReader(archivo)
        columnas=lector.fieldnames
        sql_insert= crear_instert(tabla,columnas)

        insertados=0
        reboto=0
        revertido=0
        error_critico=False

        for fila in lector:
                valores=preparar_valores(fila)
                try:
                    connection.execute(sql_insert,valores)
                    insertados+=1
                except sqlite3.IntegrityError as e:
                    reboto+=1
                    print(f"fila rechazada (IntegrityError): {valores} -  Motivo: {e}")
                except sqlite3.OperationalError as e:
                    print(f"Error Critico de Operación: {tabla},\n{e}")
                    error_critico=True
                    break
                except sqlite3.Error as e:
                    reboto+=1
                    print(f"Error inesperado de la tabla: {tabla},\n{e}")
                    error_critico=True
                    break

        print(f"-> {tabla}: ({insertados} Datos Cargados) | ({reboto} Datos Omitidos) | ({revertido} Deshacer carga por errror critico ROLLBACK)" if error_critico else f"-> {tabla}: ({insertados} Datos Cargados) | ({reboto} Datos Omitidos)")
        return {"Tabla": tabla, "insertados": insertados, "reboto": reboto, "revertido": revertido, "error_critico": error_critico}
    
    

def main():
    connection=None
    try:
        connection=sqlite3.connect(RUTA_DB)
        configuracion_pragmas(connection)#Reutiliza la funcion
        resultados=[]
        error_global=False

        for tabla,ruta_csv in RUTA_CSV.items():
            print(f"Procesando {tabla}...")
            resultado=insertar_tabla(connection,tabla,ruta_csv)
            resultados.append(resultado)
            if resultado["error_critico"]:
                error_global=True
                print(f"Se detectó un error crítico en la tabla {tabla}. Se detendrá la carga de datos.")
                break

        if error_global:
            connection.rollback()
            print("n\ROLLBACK GLOBAL: ninguna tabla quedo cargada la base de datos no se modifico.")
        else:
            connection.commit()
            total_insertados=sum(r["insertados"] for r in resultados)
            total_reboto=sum(r["reboto"] for r in resultados)
            print(f"\nResumen de la carga de datos: Total insertados: {total_insertados}, Total omitidos por error de integridad: {total_reboto}")

    except sqlite3.Error as e:
        print("Error: ",e)
        if connection:
            connection.rollback()
            print("ROLLBACK GLOBAL: ninguna tabla quedo cargada la base de datos no se modifico.")
    finally:
        if connection:
            connection.close()

if __name__=="__main__":
    main()