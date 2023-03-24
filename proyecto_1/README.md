# Proyecto 1

## Archivos

- `README.md`: Este archivo.
- `img-decrypt.S`: Descifrador.
- `img-decrypt.py`: Visualizador.
- `tests/`: Pruebas con imágenes varias.
- `doc/`: Documentación.
- `proyecto-i.pdf`: Reporte.

## Instrucciones

1. Se necesita GNU make, Python con biblioteca pillow, glibc y binutils
   (específicamente el GNU assembler y GNU linker) para un target Linux x86-64.
   Puede obtenerla manualmente o, alternativamente, utilizar `nix develop` para
   entrar en un entorno precisamente idéntico al utilizado para el desarrollo
   del proyecto. (Nota: es importante preservar .git para hacer esto, ya que
   Nix depende de los hashes criptográficos de Git para fines de
   reproducibilidad.)

2. Construir utilizando `make`.
3. Escribir un archivo de parámetros RSA y de dimensión con el formato `key =
   value`, una pareja por línea. Se necesita `d` (exponente de llave privada),
   `n` (módulo), `width` y `height`. En el directorio `tests/` hay algunos
   ejemplos.
4. Utilizar `./img-decrypt.py img.txt img.params` para descifrar y visualizar.
