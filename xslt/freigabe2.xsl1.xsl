<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Warum Freigabe? Wir wollen nicht automatisch alle beschriebenen Multimediaobjekte 
		auch nach MIMO bewegen, sondern auswählen können, was bei MIMO landet. Die 
		alte Freigabe, gab im Wesentlichen Standardbilder frei. Wie wäre es, wenn 
		wir alle digitalen Bilder freigeben (.jpg). Konkreter: Der Workflow hängt 
		an zwei Stellen von der Freigabe ab a) MPX2LIDO: In mpx werden alle existierenden 
		Multimediaobjekte angezeigt. Auf Wunsch von Paris werden in in LIDO nur solche 
		Resourcen angezeigt, die auch freigegeben/hochgeladen wurden. b) MIMO-resmvr.pl: 
		Der Faker mpx-rif hat seinen eigenen Freigabe Mechanismus. D.h. dieses Skript 
		muss die existierende Freigabe in der Regel beibehalten. Dieses Script müsste 
		dann im Wesentlichen die Freigabe für nicht gefakte multimediaobjekte erledigen. 
		Wie kann ich die nicht gefakten d.h. direkt aus M+ exportierten Multimediaobjekte 
		wie diejenigen des Borisexport erkennen? Ich könnte in die gefakten ein Attribut 
		quelle="mpx-rif" schreiben. Strategie: es wir alles Karteikarten kriegen 
		keine Freigabe. Freigegeben sind diejenigen, -->

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
				<!-- that should find only those which end of ' x' -->
				<xsl:when test="contains (mpx:multimediaDateiname, ' x') and substring-after(mpx:multimediaDateiname, ' x') = ''">
					<!-- new case: no standardbild, but still a file with x as freigabe 
						marker at end of dateiname-->
					<xsl:attribute name="freigabe">Web</xsl:attribute>
					<xsl:attribute name="priorität">
					<xsl:choose>
						<xsl:when test="contains (mpx:multimediaDateiname, '-A x')">
							<xsl:text>9</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-B x')">
							<xsl:text>8</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-C x')">
							<xsl:text>7</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-D x')">
							<xsl:text>6</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-E x')">
							<xsl:text>5</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-F x')">
							<xsl:text>4</xsl:text>
						</xsl:when>
						<xsl:when test="contains (mpx:multimediaDateiname, '-G x')">
							<xsl:text>3</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>2</xsl:text>
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
