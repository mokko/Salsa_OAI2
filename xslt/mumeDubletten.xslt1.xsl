<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Versuch, solche alten und gefakten mume auszufiltern, die inzwischen 
		neuere Datensätze in M+ haben. Ich gehe davon aus, das multimediaobjektDateiname 
		in vielen Fällen eindeutig sein sollte. Insbesondere sollte ich gefakte mumes 
		herausfiltern, wenn ein nicht-gefaktes mume dasselbe Foto beschreibt. Dasselbe 
		Foto bestimme ich hier über den Dateinamen des Fotos. Ich brauche das in 
		xslt1, um es mit perl auf den Data provier anwenden zu können. -->

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
