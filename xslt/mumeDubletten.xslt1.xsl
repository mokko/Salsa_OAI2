<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Versuch, solche alten und gefakten mume auszufiltern, die inzwischen 
		neuere Datensätze in M+ haben Ich gehe davon aus, das multimediaobjektDateiname 
		eindeutig sein sollte. -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:key name="dname" match="mpx:multimediaobjekt" use="mpx:multimediaDateiname" />

	<!-- identity <xsl:template match="node()|@*"> <xsl:copy> <xsl:apply-templates 
		select="@*" /> <xsl:apply-templates /> </xsl:copy> </xsl:template> -->

	<xsl:template match="/">
		<xsl:message>
			<xsl:apply-templates select="key(dname, 'IV Ca Nls 527')" />
		</xsl:message>
		<xsl:apply-templates select="key('dname', mpx:multimediaDateiname)" />
	</xsl:template>


</xsl:stylesheet>
