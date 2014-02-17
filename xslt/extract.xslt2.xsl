<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="2.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />
	<xsl:template match="/">
		<!-- You have to fill in a new number here to extract something -->
		<xsl:variable name="objId" select="'87009'" />
		<xsl:message>
			<xsl:text>objId: </xsl:text>
			<xsl:value-of select="$objId" />
		</xsl:message>

		<xsl:copy-of
			select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt=$objId]" />
		<xsl:for-each
			select="
/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId=$objId]/mpx:personKörperschaftRef/@id">
			<xsl:variable name="kueId" select="." />
			<xsl:message>
				<xsl:text>kueId </xsl:text>
				<xsl:value-of select="$kueId" />
			</xsl:message>
			<xsl:copy-of
				select="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId=$kueId]" />
		</xsl:for-each>
		<xsl:copy-of
			select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId=$objId]" />
	</xsl:template>
</xsl:stylesheet>
