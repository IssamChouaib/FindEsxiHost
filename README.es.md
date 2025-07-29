<div style="text-align: right;">
  [English](README.md)
</div>

# FindEsxiHost.exe — Escáner de red para ESXi

**Versión**: 1.0  
**Autor**: Issam Chouaib  
**Licencia**: Licencia GNU All‑permissive (ver LICENSE.txt)

## Descripción  
Escáner ligero para detectar servidores VMware ESXi operativos en una LAN mediante TCP puerto 902 sin necesidad de autenticación. Empaquetado como ejecutable portátil con interfaz gráfica en Windows PowerShell 5.1.

## Funcionalidades
- Escaneo de rango IP configurable con conexión TCP asíncrona (`BeginConnect`) y timeout por defecto de **50 ms**.
- Identificación de ESXi mediante análisis del banner inicial por las palabras “VMware” o “esx”.
- Interfaz WinForms moderna con botón de inicio, barra de progreso y tabla de resultados.
- Botón único **Export Results** para generar archivos de salida en formatos TXT, CSV o HTML.
- Portátil: no requiere instalación, ejecutable independiente para Windows.

## Uso
1. Ejecuta `FindEsxiHost.exe`.
2. Introduce **Start IP**, **End IP** y **Timeout (ms)**.
3. Haz clic en **Start Scan**.
4. Observa los resultados en la tabla.
5. Pulsa **Export Results** para guardar los datos.

## ¿Por qué usar esta herramienta?  
Permite detectar servidores ESXi de forma rápida y fiable en entornos LAN, ideal para administración de sistemas, inventario o auditoría. No requiere dependencias ni instalación.

## Licencia  
Este proyecto está licenciado bajo la **Licencia GNU All‑permissive**. Consulta [LICENSE.txt](LICENSE.txt) para los términos completos.

## Archivos incluidos
- `FindEsxiHost.exe` — ejecutable del escáner.
- `README.md`, `README.es.md` — documentación bilingüe.
- `LICENSE.txt` — información legal de licencia.
