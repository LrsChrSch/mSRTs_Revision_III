# Unbetiteltes Projekt

## TODO:
- Sound (Beide)
- Projekttitel (Beide/Lars)
- Texte überarbeiten (Lars)
- Website Titel / Meta Description, etc. (Lars)


## Parameterliste

### Formen
- Matrix Count (3-5): Dieser Parameter beschreibt die Grundform des Fraktals (3 sind immer pyramiden-artige Formen, ab 4 ist die Grundform nicht mehr wirklich erkennbar). Grundsätzlich bedeuten höhere Werte hier, dass die Form 'aufgefächerter'/'ungenauer'/'variabler' ist
- Scale (0-1): Je höher Scale ist, desto 'geometrischer' werden die Formen in der Regel. Die Punkte schwirren weniger im Raum rum und bilden präzisere Formen
- Rotation (0-1): Dieser Wert ist am schwierigsten zu erklären. Rotation hat aber trotzdem einen großen Effekt auf die Form. Sehr kleine Werte lassen die Form "aufgebauscht" und "wolkenartig" erscheinen. Sonst sind (meiner Meinung nach) nicht sehr viele Eigenschaften klar benennbar. Es kommt hier halt sehr auf die anderen Werte an.

Grundsätzlich sind diese Werte eher Richtwerte. Die Formen sind sehr zufällig generiert und können immer auch abweichen.

### Szene
- Kameraposition relativ zum Mittelpunkt (Orbit von 10 Einheiten auf jeder Achse): -10 bis +10
- Kamerarotation als Winkel auf 2 Achsen (Pitch und Yaw)
	- K.A. ob man das benutzen kann. Vllt für räumlichen Sound
- Distanz zum Mittelpunkt (abgeleitet aus der Kameraposition): 0-10
- Welche jetzige Form gerade im Mittelpunkt ist (am ehesten in Verbindung mit den Werten oben): Index 0-319, also 320 Formen insgesamt
- Welche Formen gerade außen herum sind als Bilder (Liste aus Indexen 0-319)
- 2D Mausposition (entweder als Pixel oder besser als UV-Koordinaten): -1 bis +1 oder 0 bis 1 für X und Y Achse
- Ob und welche Form gerade mit der Maus gehovered wird: Boolean und/oder Index
- Generelle Position im großen Raum. Kurze Erkärung dazu: man bewegt sich zwar nur um den Mittelpunkt, aber der Mittelpunkt bewegt sich über Zeit im großen Raum. Ich hatte geplant, dass je weiter raus man geht, desto weniger Bilder/Texte kommen noch und man landet irgendwann einfach im "Void", außerhalb von allem.
Dieser Punkt sollte so nach ca. 100 Einheiten in jede Richtung kommen (also bei 100 sind noch alle Bilder da, aber zwischen 100-200 sollen es immer weniger werden, bis dann irgendwann (quasi zufällig) der Punkt kommt, wo man halt nicht mehr zurück kann)
Da bin ich mir aber auch noch nicht ganz sicher, ob das dramaturgisch funktioniert. Ich glaube aber schon.
Deswegen: Position im Raum (-200 bis 200 für 3 Achsen) und vllt. auch ein Wert, der angibt, wie viel noch übrig ist (linear interpolierte Range von 0-100-200 zu 1-1-0)
- Die Generelle Position beschreibt gleichzeitig auch die Entfernung auf den Achsen:
	- Signal/Noise (links/rechts): normalisiert -1 bis +1
	- Meta/Infra (oben/unten): normalisiert -1 bis +1
	- Emergent/Constructed (hinten/vorne): normalisiert -1 bis +1
- Übergang des Mittelpunkts:
	- Ob der Übergang gestartet wurde: Trigger
	- Ob der Übergang beendet wurde: Trigger
	- Wie weit der Übergang fortgeschritten ist: Nummer 0-1, wird animiert innerhalb der paar Sekunden
- Übergang der Elemente (Bild+Text) außen:
	- Jedes Element hat eine eigene Animation und verschwindet mit leichtem Delay von oben nach unten. D.h. alle Übergangsparameter (Trigger+Fortschritt) gibt es auch für einzelne Bilder
	- Texte haben jetzt gerade keinen hover/click-Effekt, könnte man aber auch wieder einbauen
Der gesamte Übergang aller Elemente beim Klick dauert ca. 3-3.5 Sekunden und folgt weitestgehend einer cubic-in-out-Kurve
- Interactions Counter: Wie oft man schon die Position gewechselt hat (wie viele Klicks auf Bilder gegangen sind). Je mehr Klicks, desto mehr Bilder und weniger Text gibt es in der Szene. Das ganze bei 20 Interaktionen geclamped (kann man noch ändern): Deswegen 0-20 oder normalisiert 0-1 (Fortschritt durch die Website im Prinzip)
	- Damit verbunden ist die weiße Linie, die man hinter sich herzieht. Diese hat eine Liste mit mehreren Positionen (jeweils x,y,z in globalen Koordinaten -200 bis +200) und natürlich eine Listenlänge (0-unendlich theoretisch)
- Theoretisch gibt's noch mehr Parameter wie die Anzahl an Instanzen, aus der eine Form besteht (immer ca. 200.000) oder wo der durschnittliche Punkt einer Form ist (normalisiert -1 bis +1)
- Konstant: Die Szene hat auch noch ein visuelles Post-Processing-Rauschen. Das verändert sich nicht, könnte aber auch im Sound enthalten sein.
- Konstant: Nach ca. 15 Einheiten verdeckt außerdem Nebel die Szene. Das hat keine Auswirkung auf die Bilder/Texte/Formen, aber die Linien verschwinden bspw. darin

Es lassen sich auch Geschwindigkeiten ableiten (bspw. für die Kameraposition oder den Mittelpunkt). Ist noch nicht im Programm drin, aber die sollten dann in Einheiten/Frame oder Einheiten/Sekunde angegeben sein.
Eine Einheit würde ich am ehesten mit einem Meter gleichsetzen (ist aber auch nicht so wichtig)

### Startbildschirm
- Den Button in der Mitte zum Entern: Trigger (mit anschließender Animation über 2.5 Sekunden)




## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.
