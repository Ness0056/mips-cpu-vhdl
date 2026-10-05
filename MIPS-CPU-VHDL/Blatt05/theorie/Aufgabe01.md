# VHDL-Attribute (2 Punkte)

Hinweis: Zur Lösung der Theorieaufgaben ist einfach dieses Dokument zu bearbeiten,
dann mit Git zu committen und die Änderung dann ins Gruppen-Repository zu pushen.

Mithilfe von Attributen kann in VHDL auf bestimmte Eigenschaften von Signalen zugegriffen werden.
Informieren Sie sich zum Beispiel in [1] über Attribute in VHDL und beantworten Sie die folgenden Fragen:

1. Wie greifen Sie auf das Attribut eines Signals zu? Geben Sie die Syntax anhand eines Beispiels an.

    Man greift in VHDL auf ein Attribut zu, indem man nach dem Signalnamen mit `'` (Apostroph) den Attributnamen anhängt: 
    `signal_name'atrribute_name`

    z.b liefert `clk_in'length` die Breite von `clk_in` (Die Anzahl von Bits)

2. Nennen Sie drei der im Standard vordefinierten Attribute und erklären Sie kurz, was sie repräsentieren.

    - `signal_name'length`: Die Anzahl der Elemente (z.B. Bits) in einem Vektor oder Array
    - `signal_name'event`: Zeigt an, ob es bei dem Signal in diesem Simulationsschritt eine Wertänderung gab (true/false)
    - `signal_name'left`: Der Index des linken (meist höchsten) Elements eines Arrays oder Vektors

3. Über welche Attribute erhält man den Gültigkeitsbereich des Index für Signale des Typs std_logic_vector?

    Für den Indexbereich nutzt man folgende Attribute:
    - `'left`: Index des "linken" (erstdeklarierten) Elements.
    - `'right`: Index des "rechten" (letztdeklarierten) Elements.
    - `'range`: Bereich aller gültigen Indizes des Vektors (z.B. 7 downto 0).

    Zusätzlich gibt es `'low` und `'high` für kleinsten/größten Indexwert.

4. Wie kann man in VHDL mithilfe von Attributen eine positive bzw. negative Flanke eines Signals detektieren? Geben Sie die entsprechenden VHDL-Anweisungen an.

    - Positive Flanke (`rising_edge(signal)`):
      ```vhdl
      if clk'event and clk = '1' then
        -- positive Flanke erkannt
      end if;
      ```

    - Negative Flanke (`falling_edge(signal)`):
      ```vhdl
      if clk'event and clk = '0' then
        -- negative Flanke erkannt
      end if;
      ```
