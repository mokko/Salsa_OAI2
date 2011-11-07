<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mpx.org/mpx"
	xmlns:mpx="http://www.mpx.org/mpx">

	<!-- Fix #1: Add multimediaobjekt/@typ where attribute does not yet exist -guess
		type based on file extension, -fill in a value only if no value exists already 
		-current
		values: Bild|Audio|Video -->
	<xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt[not (@typ)]">
		<xsl:message>
			<xsl:text>//mpx:multimediaobjekt/@typ: add typ based on multimediaErweiterung</xsl:text>
		</xsl:message>
		<xsl:copy>
			<xsl:attribute name="typ">
			<xsl:call-template name="choosetyp" />
		</xsl:attribute>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

	<!-- Fix #2: Add multimediaobjekt/@freigabe -->
	<xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt[not (@freigabe)]">
		<xsl:message>
			<xsl:text>///mpx:multimediaobjekt/@freigabe: add default value</xsl:text>
		</xsl:message>

		<xsl:copy>
			<xsl:attribute name="freigabe">
			<xsl:text>intern</xsl:text>
		</xsl:attribute>

			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>


	<xsl:template name="choosetyp">
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

		<xsl:variable name="ext"
			select="translate(mpx:multimediaErweiterung, $uppercase, $smallcase)" />
		<!-- xsl:message><xsl:value-of select="$ext"/></xsl:message -->
		<xsl:choose>
			<xsl:when test="$ext = 'jpg' or 
				$ext = 'tif' or 
				$ext = 'tiff'">
				<xsl:text>Bild</xsl:text>
			</xsl:when>
			<xsl:when test="$ext = 'mp3' or 
				$ext = 'wav'">
				<xsl:text>Audio</xsl:text>
			</xsl:when>
			<xsl:when test="$ext = 'mpeg' or 
				$ext = 'mpg' or 
				$ext = 'avi'">
				<xsl:text>Video</xsl:text>
			</xsl:when>
			<xsl:when test="$ext = 'wpd'">
				<xsl:text>Text</xsl:text>
			</xsl:when>
			<xsl:when test="$ext = ''">
				<xsl:message>
					<xsl:text>Add multimediaobjekt/@typ: Erweiterung empty; assume </xsl:text>
					<xsl:text>default "Bild"</xsl:text>
					<!-- xsl:value-of select="text(.)" / -->
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>Warning: Erweiterung unbekannt:</xsl:text>
					<xsl:value-of select="$ext" />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>