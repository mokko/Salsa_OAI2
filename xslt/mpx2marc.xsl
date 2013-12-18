<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:marc21="http://www.loc.gov/MARC21/slim"
	xmlns:mpx="http://www.mpx.org/mpx"
	exclude-result-prefixes="mpx"
>

	<!-- xsl:import href="mpx2marc/record.xsl"/-->

	<!-- mpx2marc : convert mpx to MARC21. This mapping is not meant for production. It's
		just a test.  I am mostly trying to learn MARC. Hence, I am not concerned much with
		the
	proper formatting of the fields' content, i.e. that which normally is covered
		by AACR2, RDA and friends. -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<marc21:collection xsi:schemaLocation="http://www.loc.gov/MARC21/slim ../xsd/MARC21slim.xsd">
			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt"/>
		</marc21:collection>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">

		<!-- Salsa_OAI doesn't like message too much <xsl:message> <xsl:text>objId:</xsl:text>
			<xsl:value-of
			select="@objId"/>
			</xsl:message>
			-->

		<marc21:record type="Bibliographic">

			<!--xsl:value-of select="concat ('spk:obj-',@objId)"/
			<xsl:call-template name="descriptiveMetadata"/>-->
		</marc21:record>
	</xsl:template>
</xsl:stylesheet>