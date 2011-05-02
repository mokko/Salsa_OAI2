<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="objectMeasurementsWrap">
        <xsl:if test="child::mpx:maßangabe">
            <lido:objectMeasurementsWrap>
                <xsl:apply-templates select="child::mpx:maßangabe"/>
            </lido:objectMeasurementsWrap>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mpx:maßangabe">
        <lido:objectMeasurementsSet>
            <lido:displayObjectMeasurements>
                <xsl:value-of select="."/>
            </lido:displayObjectMeasurements>
        </lido:objectMeasurementsSet>
    </xsl:template>
    
</xsl:stylesheet>
