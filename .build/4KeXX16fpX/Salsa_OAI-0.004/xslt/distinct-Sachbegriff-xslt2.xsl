<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpx="http://www.mpx.org/mpx"
    exclude-result-prefixes="mpx">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements=""/>

    <xsl:template match="/">
        <sachbegriffe>
            <xsl:for-each-group select="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff"
                group-by=".">
                <xsl:sort data-type="text" lang="de" order="ascending"/>
                <xsl:element name="term">
                    <xsl:attribute name="count">
                        <xsl:value-of select="count(current-group())"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each-group>
        </sachbegriffe>

    </xsl:template>
</xsl:stylesheet>
