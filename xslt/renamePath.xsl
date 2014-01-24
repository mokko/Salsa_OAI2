<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xpath-default-namespace="mpx"
	exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- JUST CHANGING THE PATH OF OLD FAKED IMAGES etc. -->

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

	<xsl:template match="mpx:multimediaobjekt/mpx:multimediaPfadangabe">
		<xsl:choose>
			<xsl:when test="contains (., 'R:\MIMO-JPGS_Ready-To-Go\')">
				<xsl:element namespace="http://www.mpx.org/mpx" name="{name()}">
					<xsl:text>W:\MIMO\MIMO-JPGS_Ready-To-Go</xsl:text>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
