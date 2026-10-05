# Aufgabe 1: Automaten (5 Punkte)
**Informieren Sie sich (z.B. in [1, ab Seite 273]) über endliche Zustandsautomaten.
Erarbeiten Sie insbesondere den Unterschied zwischen Moore- und Mealy-Automaten (z.B. [1, ab Seite 279]).
Beantworten Sie anschließend die folgenden Fragen:**

## 1. Was ist ein endlicher Zustandsautomat? (1 Punkt)

Ein endlicher Zustandsautomat ist ein Modell zur Beschreibung von Systemen mit endlich vielen Zuständen, abhängig von Eingaben zwischen diesen Zuständen wechselt und dabei Ausgaben erzeugen kann.

## 2. Wie unterscheiden sich Moore- und Mealy-Automaten voneinander? Nennen Sie für beide Varianten jeweils einen Vorteil! (2 Punkte)

**Moore-Automat**: Ausgabe hängt nur vom aktuellen Zustand ab  
*Vorteil*: Ausgaben sind stabil und ändern sich nur bei Zustanswechseln 

**Mealy-Automat**: Ausgabe hängt vom aktuellen Zustand un den Eingaben ab  
*Vorteil*: Schnellere Reaktion auf Eingaben, oft weniger Zustände nötig 

## 3. In VHDL lassen sich Automaten über ein bis mehrere Prozesse realisieren. (2 Punkte)
### Wonach wird bei einer Mehrprozessimplementierung die Logik aufgeteilt und was sind die Vorteile davon?

Typisch werden Sie in bis zu drei Prozesse zerlegt:

- Ein sychronen Prozess für das Zustandsregister (aktueller Zustand)
- Ein kombinatorischen Prozess für die Zustandsübergänge (nächster Zust.)
- Ein Kombinatorischen Prozess für die Ausgabelogik

Alternativ wird nach Aufgaben augeteilt:
- Takt-\Speicherlogik in einem Synchronen Prozess
- Reine Kombinatorik (Übergänge und Ausgänge) in Kombinatorischen Prozessen.

**Vorteile**:
- Besssere Übersichtlichkeit 
- Einfachereres Debugging 
- Verbesserte Sythesefähigkeit und Fehlervermeidung, klare Trennung von synchroner und kombinatorischen Logik

### In bis zu wie viele Prozesse ist eine Aufteilung bei einer Mehrprozessimplementierung sinnvoll?

Bis zu drei Prozesse (Zustand, Übergang, Ausgabe).
Mehr Prozesse bringen in der Regel keinen zusätzlichen Vorteil.


# Literatur
[1] David A. Patterson and John L. Hennessy. Rechnerorganisation und -entwurf. Spektrum Akademischer Verlag, September 2005.

