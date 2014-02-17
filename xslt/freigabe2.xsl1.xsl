<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- 
	1. Warum überhaupt eine Freigabe? 
	Wir wollen nicht automatisch alle Multimediaobjekte im Web sichtbar machen, sondern auswählen, 
    was online in LIDO/MIMO sichtbar ist.  

	2. Workflow Basics
	In mpx werden alle Multimediaobjekte-Metadaten gezeigt. Allerdings habe diese keine URL, die 
	auf die eigentliche Resource (Bild) verweist.
	
	Für MIMO laden wir Bilder auf den Pariser Medienserver hoch. Die URL lässt sich aus der
	mulId ableiten und ist in LIDO enthalten.

	Auf Wunsch von Paris werden nur solche Resourcen-Metadaten in Lido angezeigt, die auch ein
	Resource (Bild) haben.		

	3. Welche Attribute hängen von der Freigabe ab?
	Es handelt sich um Attribute von mpx:multimediaobjekt
	
	freigabe='Web|intern'
	quelle='mpx-rif' (nur für gefakte Objekte)	
	priortität=Integer. 
		Je niedriger die Zahl, desto höher die Priortität. Jede Zahl sollte pro
		verlinktem Objekt nur einmal vergeben werden. LIDO sortiert die Multimediaobjekte pro
		Sammlungsobjekt so, dass die Resource (Bild) mit der niedrigsten Priorität die bevor-
		zugte Ansicht ist.

	typ='Bild|Audio|Video' (nur für gefakte Objekte?)			
	
	4. Update-Politik
	Eine alte Fassung des Freigabe-Skripts veränderte nur Freigaben für Multimediaobjekten
	die noch keine Freigabe Attribut hatten. Die neue Fassung verändert potentiell alle 
	Freigaben.
	
	5. Gefakte Daten
	2011 verwendeten wir gefakte Multimedia-Daten. D.h. mit einem separaten Skript haben
	wir multimediaobjekt-Daten zu Files erzeugt ohne sie vorher in M+ einzugeben. Inzwischen
	sollen diese Daten in M+ importiert worden sein. Es gibt aber immer noch gefakte 
	Multimediaobjekt-Daten, obwohl wir mume-Dubletten bereits herausgefiltert haben.
	
	6. Freigabe-Algorithmus	

	Freigabe könnte auf folgenden Informationen beruhen
		1) im Dateinamen kodiert, z.B. "vii c 1234c x -A"
		2) Information, ob Resource als Standardbild gekennzeichnet ist oder nicht. Obwohl
		   M+ immer nur 1 Standardbild zu einer Zeit haben kann, ist es denkbar das ein mpx
		   Sammlungsobjekt mehr als ein Standardbild besitzt (wenn sich das Standardbild im Laufe
		   der Zeit geändert hat und beide Situationen exportiert wurden).
		3) aktuellem Freigabe-Integer (nicht gut, weil das Skript dann bei mehrmaligem Ausführen
		   keine konstanten Ergebnisse erzeugt.)
		4) Man kann nur sicherstellen, dass jeder Freigabe-Integer pro verknüpftes Objekt distinkt 
		   (eindeutig) ist, wenn man diese Menge von Mume nach entsprechenden Werten durchsucht. 

	Alter Algorithmus
		1. Wenn als Standardbild gekennzeichnet und keine Karteikarte (' -KK' in Dateiname)	
			freigabe='Web' und priorität=10
		2. Wenn Dateiname auf x endet
			freigabe='Web'
		   Priorität ergibt sich aus Buchstabencode vor x 
				'-A x' wird 9
				'-B x' wird 8

	Beabsichtigt ist, dass Freigabe durch Buchstabencode im Dateiname eine höhere Priorität (kleiner 
	Integer) besitzt als Freigabe durch Standardbild. Es ist aber nicht beabsichtigt, dass -A eine
    niedrigere Priorität (größerer Integer) besitzt als -B. Also ist dieser Logarithmus verkehrt.
		
	Nicht-Eindeutiger Priorität-Integer	
	Außerdem wird hier nicht mit Sicherheit festgestellt, dass Integer pro verknüpftes Objekte eindeutig 
	ist. Das Problem hierbei ist, dass so lange Priorität nicht festgestellt wurde ich die entsprechenden
	Werte nicht vergleichen kann. Selbst wenn ich sie vergleichen könnte (z.B. mittels einer weiteren
    Transformation), weiß ich nicht welche Resource dann die höhere Priorität erhalten sollte. Also
	bleibe ich beim bisherigen Verfahren, wo diese Entscheidung bei nicht eindeutigem Integer von mpx2lido
	Transformaton getroffen wird (todo: check).	 	
	
	Neuer Algorithmus
	Ich muss also nur den oben beschriebenen Fehler korrigieren
	-A x erhält höchste Priorität (1)							
	-B x erhält höchste Priorität (2)
		etc.							
	Standardbild erhält Priorität 10		
-->
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- remove schemaLocation if any -->
	<xsl:template match="@xsi:schemaLocation" />

	<!-- identity -->
	<xsl:template match="node()|@*">

		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="mpx:multimediaobjekt">
		<!-- Usually we need to copy all existing attributes -->
		<xsl:element namespace="http://www.mpx.org/mpx" name="{name()}">
			<xsl:apply-templates
				select="@exportdatum|@mulId|@quelle|@freigabe|@priorität" />

			<!-- overwrite existing freigabe -->
			<xsl:choose>
				<!-- standardbild wird freigeben, ausser wenn Karteikarte '-KK' -->
				<xsl:when test="mpx:standardbild and not(contains (mpx:multimediaDateiname, ' -KK'))">
					<xsl:attribute name="freigabe">Web</xsl:attribute>
					<xsl:attribute name="priorität">10</xsl:attribute>
				</xsl:when>
				<!-- that should find only images whose dateiname ends with ' x' -->
				<xsl:when test="contains (mpx:multimediaDateiname, ' x') and substring-after(mpx:multimediaDateiname, ' x') = ''">
					<!-- new case: no standardbild, but still a file with x as freigabe 
						marker at end of dateiname-->
					<xsl:attribute name="freigabe">Web</xsl:attribute>
					<xsl:attribute name="priorität">
					<xsl:choose>
						<xsl:when test="contains (mpx:multimediaDateiname, '-A x')">
							<xsl:text>1</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-B x')">
							<xsl:text>2</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-C x')">
							<xsl:text>3</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-D x')">
							<xsl:text>4</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-E x')">
							<xsl:text>5</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-F x')">
							<xsl:text>6</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-G x')">
							<xsl:text>7</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-H x')">
							<xsl:text>8</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>9</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="freigabe">intern</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="child::*" />
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
