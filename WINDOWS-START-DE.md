# ChipWhisperer Windows Starter

Basis: newaetech/chipwhisperer, Commit 8406f685e67e19c758b391ee75c94607260ac732.

1. ZIP vollstaendig in einen kurzen, beschreibbaren Pfad entpacken, z. B. C:\CW. Nicht in Programme ablegen.
2. Python >= 3.11 (64 Bit) von https://www.python.org/downloads/windows/ mit Python Launcher installieren.
3. START.cmd doppelklicken. Der erste Start braucht Internet und installiert die Pakete mit pip --user fuer deinen Windows-Benutzer in der ausgewaehlten Python-Installation. Danach oeffnet sich JupyterLab im Browser. Das Terminal offen lassen.
4. Notebooks unter jupyter oeffnen. DIAGNOSE.cmd listet angeschlossene ChipWhisperer-Geraete auf, ohne Firmware zu flashen.

USB-Treiber: Falls das Geraet nicht erkannt wird, die offiziellen NewAE Windows-Treiber gemaess https://chipwhisperer.readthedocs.io/en/latest/windows-install.html installieren. Treiberinstallation kann Administratorrechte erfordern. Ein fehlendes Geraet verhindert den Start von Jupyter nicht.

ChipWhisperer Nano: In Jupyter NANO_START.ipynb oeffnen. Das Notebook verwendet explizit CWNano. Die Verbindungszelle konfiguriert die Hardware mit default_setup(), fuehrt aber kein Firmware-Update durch.

Nano-Target-Firmware bauen: NANO_BUILD.cmd startet die native Windows-Toolchain. Beim ersten Aufruf wird MSYS2 ueber winget eingerichtet, aktualisiert und mit GNU Make, ARM-GCC und newlib ergaenzt. Internet ist erforderlich, der Installer kann Administratorrechte verlangen. MSYS2 ist eine Windows-Werkzeugsammlung, kein WSL und keine virtuelle Maschine. Bei einem MSYS2-Basisupdate kann ein zweiter Aufruf erforderlich sein. Bei bereits vorhandenem MSYS2 CW_MSYS2 auf dessen Ordner setzen, beispielsweise C:\msys64; andernfalls wird tools/msys64 verwendet. Eine bestehende MSYS2-Installation wird dabei aktualisiert.

Der Build verwendet PLATFORM=CWNANO, CRYPTO_TARGET=TINYAES128C und SS_VER=SS_VER_1_1 und erzeugt firmware/mcu/simpleserial-aes/simpleserial-aes-CWNANO.hex. Es wird nichts automatisch geflasht. Andere Targets, Notebooks und Toolchains sind damit nicht abgedeckt. Windows-Build und USB-Verbindung konnten hier nicht praktisch getestet werden.

Die lokale ExecutionPolicy-Option in START.cmd gilt nur fuer diesen PowerShell-Prozess. Globale Windows-Einstellungen werden nicht veraendert. Jupyter bleibt auf 127.0.0.1 beschraenkt und behaelt seine Token-Authentifizierung.

Dies ist ein Starter mit automatisierter Python-Einrichtung, kein vollstaendig offline lauffaehiger Installer. Python, USB-Treiber und optionale Compiler sind nicht eingebettet. Python-Abhaengigkeiten werden beim ersten Start aus PyPI aufgeloest und sind nicht vollstaendig versionsfixiert. Zum Wiederholen der Einrichtung windows-ready/setup-python.txt loeschen. Es wird keine virtuelle Umgebung angelegt. Pakete werden mit anderen Anwendungen derselben Python-Installation geteilt. Der Starter verwendet py -3, ersatzweise python aus PATH. Mit der Umgebungsvariable CW_PYTHON kann ein konkreter python.exe-Pfad ausgewaehlt werden. Bereits aktivierte virtuelle Umgebungen werden abgewiesen. Ein Ordnerwechsel erfordert das Loeschen der Setup-Markierung, da ChipWhisperer editierbar installiert wird.

Validierung: Python-Diagnoseskript syntaktisch geprueft; Paketinhalt und referenzierte Pfade geprueft. Windows-Ausfuehrung, Treiber und echte Hardware konnten in der Linux-Buildumgebung nicht getestet werden. Upstream-Lizenzen bleiben enthalten.
