--      Entity "or2"
--             ┌─────────┐
--     a ──────┤         ├────── y
--             │   or2   │
--     b ──────┤         │
--             └─────────┘

-- Es werden lediglich die Ports (Ein- und Ausgänge) definiert. ("Blackbox")
entity or2 is
    port (
        a : in bit;
        b : in bit;
        y : out bit
    );
end or2;

--      Architecture "or2"
-- Eingangs- und Ausgangsport werden nicht explizit definiert, sondern vom Entity übernommen.
-- Es wird die eigentliche Logik definiert. ("Inhalt der Blackbox")
architecture behavioral of or2 is
begin
    y <= a or b;
end architecture;
