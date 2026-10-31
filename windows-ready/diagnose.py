"""Read-only USB enumeration; does not flash or configure connected devices."""
import sys
import traceback
import chipwhisperer as cw
print('Python:', sys.version)
print('ChipWhisperer:', cw.__version__)
try:
    devices = cw.list_devices()
    print('USB devices:', devices)
    if not devices:
        print('Kein Geraet gefunden. USB-Datenkabel, Stromversorgung und Windows-Treiber pruefen.')
except Exception:
    traceback.print_exc()
    print('USB-Zugriff fehlgeschlagen. Offizielle NewAE USB-Treiber pruefen.')
    sys.exit(1)
