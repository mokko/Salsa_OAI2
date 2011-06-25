<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    
    distill distinct Sachbegriffe out of an mpx document 
    input: for the time being we assume we have a big mpx file with all the 
    files as input which might not be an ideal input

-->
    
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpx="http://www.mpx.org/mpx"
    exclude-result-prefixes="mpx">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements=""/>

    <xsl:key name="terms" match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff/text()"
        use="."/>

    <xsl:template match="/">
        <!-- 
            Dauert zu lange
            <xsl:attribute name="count">
            <xsl:value-of
            select="count (
            /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff/text()[generate-id()=generade-id()]
            )"/>
            </xsl:attribute>
        -->
        <sachbegriff>
            <xsl:for-each
                select="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff/text()[generate-id()=generate-id(key('terms',.)[1])]">
                <xsl:sort data-type="text" lang="de" order="ascending"/>
                <xsl:element name="term">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
        </sachbegriff>
    </xsl:template>
</xsl:stylesheet>
