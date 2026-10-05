# Aufgabe 1: Mehrzyklenprozessoren

Mehrzyklenarchiketuren wurden entwickelt, um die Leistung von Einzyklusarchitekturen zu verbessern. Informieren Sie sich (z.B. in [1, ab Seite 273]) über Leistungsbegrenzungen von Singlecycle-Architekturen und der Entwicklung von
Multicycle-Implementierungen.

**WICHTIG:** *Mehrzyklenarchiketuren* sind etwas anderes als *Pipelining*.
In dieser Aufgabe geht es **nicht** um Pipelining.
Beide Ansätze dienen der Verbesserung der Timingperformance, unterscheiden sich jedoch in der Umsetzung, in der konkreten Performanceverbesserung und in ihren Vor- und Nachteilen.


Beantworten Sie die folgenden Fragen:

## 1. Timingperformance (3 Punkte)
**Timingperformance ist der wichtigste Grund, warum Einzyklus-Prozessoren heutzutage höchst selten zu finden sind.**

**Erklären Sie das hauptsächlichen Leistungsproblem einer Singlecycleimplementierung.**

Alle Instruktionen brauchen genau ein Takt , deshalb muss dieser Takt so lang sein wie dies langsamste Instruktion (z.b lw)

**Geben Sie ein numerisches Beispiel an, das erlaubt, dieses Problem abzuschätzen.**

Bsp.: Langsamte Instruktion braucht 800 ps , auch einfache add-Instruktionen müssen 800 ps warten . 

Wenn ein Mehrzyklus‑Prozessor die Instruktion auf 5 Schritte à 160 ps aufteilt, hat er 5 Takte, aber jeder Takt ist kurz:

Einzyklus: 1 Takt × 800 ps = 800 ps pro Instruktion.

Mehrzyklus: z.B. Ø 4,5 Takte × 160 ps ≈ 720 ps pro Instruktion → schneller.


## 2. Mehrzyklenimplementierung (1 Punkt)

**Wie verbessert eine Mehrzyklenimplementierung dieses Problemen?**

Jede Stufe (z.B. nur ALU, nur Speicherzugriff) bekommt einen eigenen Takt.

Der Takt richtet sich nur nach der langsamsten Stufe, nicht nach der ganzen langen Kette.

Einfache Instruktionen brauchen weniger Takte als komplexe, daher ist die durchschnittliche Ausführungszeit kleiner als beim Einzyklus‑Design.


## 3. Vorteile einer Mehrzyklenimplementierung (1 Punkt) 
**Ist Timingperformance die einzige Verbesserung einer Mehrzyklenimplementierung?**

Nein, siehe folgende Punkte:

**Wie verhält es sich mit den benötigten Hardwareressourcen und der Leistungsaufnahme?**

Hardware: Viele Bausteine werden wiederverwendet (z.B. eine ALU für mehrere Schritte), daher braucht man weniger parallele Hardware als beim Einzyklus‑Prozessor.

Leistungsaufnahme: Weniger Logik ist gleichzeitig aktiv → oft geringere Energie pro Instruktion.

Nachteil: Eine einzelne Instruktion braucht mehrere Takte, also ist die Steuerung (FSM, Zustandsautomat) etwas komplizierter.



## Quellen

[1] David A. Patterson and John L. Hennessy. Rechnerorganisation und -entwurf. Spektrum Akademischer Verlag, September 2005.
