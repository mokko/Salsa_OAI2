<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpx="http://www.mpx.org/mpx"
	exclude-result-prefixes="mpx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no" />
	<xsl:strip-space elements="" />

	<xsl:template match="/">
		<xsl:for-each-group select="/mpx:museumPlusExport/mpx:multimediaobjekt"
			group-by="@id">
			<xsl:sort data-type="text" lang="en" order="ascending" />
			<xsl:message>
				<xsl:value-of select="count(current-group())" />
				<xsl:text>:</xsl:text>
				<xsl:value-of select="." />
			</xsl:message>
		</xsl:element>
		</xsl:for-each-group>
	</sachbegriffe>

	</xsl:template>
</xsl:stylesheet>
