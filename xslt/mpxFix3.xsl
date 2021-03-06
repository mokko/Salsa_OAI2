<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mpx.org/mpx"
	xmlns:mpx="http://www.mpx.org/mpx">

	<!--
		Another attempt at fixing mpx.

		Conditions and limitations:
		-input and output are mpx.
		-do not produce errors if applied multiple times
		-do not assume that you can access records other than the current one,
		so that I can apply this fix to SalsaOAI store via transform.pl
	-->

	<xsl:include href="mpxFix3/multimediaobjekt.xsl" />
	<xsl:include href="mpxFix3/sammlungsobjekt.xsl" />

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no" />
	<xsl:strip-space elements="*" />

	<!-- Identity -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

	<!--
		TEMPLATES APPLYING TO MULTIPLE OBJECT TYPES

		Fix #1: Add mpx:geogrBezug/@funktion
		-only where attribute does not exist yet
		-fill in default value "Herkunft (Allgemein)"

		TODO: Here is something wrong with the export. No other values than
		default!
	-->
	<xsl:template match="//mpx:geogrBezug[not (@funktion)]">
		<xsl:message>
			<xsl:text>//mpx:geogrBezug/@funktion: add default value</xsl:text>
		</xsl:message>
		<xsl:copy>
			<xsl:attribute name="funktion">
			<xsl:text>Herkunft (Allgemein)</xsl:text>
		</xsl:attribute>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>