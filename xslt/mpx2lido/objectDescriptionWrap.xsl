<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="objectDescriptionWrap">
        <xsl:if test="child::mpx:kurzeBeschreibung or child::mpx:langeBeschreibung">
            <lido:objectDescriptionWrap>
                <xsl:apply-templates select="child::mpx:kurzeBeschreibung"/>
                <xsl:apply-templates select="child::mpx:langeBeschreibung"/>
            </lido:objectDescriptionWrap>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mpx:kurzeBeschreibung|mpx:langeBeschreibung">
        <lido:objectDescriptionSet>
            <lido:descriptiveNoteValue xml:lang="de">
                <xsl:value-of select="."/>
            </lido:descriptiveNoteValue>
        </lido:objectDescriptionSet>
    </xsl:template>
    
</xsl:stylesheet>
