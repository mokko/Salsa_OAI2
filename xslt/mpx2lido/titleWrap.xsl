<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:import href="sachbegriff-thesaurus.xsl"/>

    <!-- FOURTH LEVEL -->

    <xsl:template name="titleWrap">

        <!--
            titleSet/appellationValue
            Should we involve sachbegriff and titel ? I guess so, but how exactly
            According to lido-v0.7.xsd titleSet is repeatable, MIMO D2.1 is contradicting itself
            TODO: Currently, I put all mpx:sachbegriff and mpx:titel. Probably not good.
        -->
        <!--xsl:value-of select="'DEBUG:mpx:sachbegriff exists'"/-->
        <lido:titleWrap>
            <xsl:choose>
                <xsl:when test="child::mpx:titel">
                    <xsl:for-each select="child::mpx:titel">
                        <lido:titleSet>
                            <lido:appellationValue>
                                <xsl:value-of select="."/>
                            </lido:appellationValue>
                        </lido:titleSet>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="child::mpx:sachbegriff">
                    <xsl:for-each select="child::mpx:sachbegriff" xml:space="preserve">
                        <lido:titleSet>
                            <lido:appellationValue><xsl:value-of select="."/></lido:appellationValue>
                        </lido:titleSet>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- otherwise: If neither mpx:titel or mpx:sachbegriff, write nothing & create a non-validating lido so we can find the error easily-->
                    <lido:titleSet>
                        <lido:appellationValue> kein Titel </lido:appellationValue>
                    </lido:titleSet>
                </xsl:otherwise>
            </xsl:choose>
        </lido:titleWrap>
    </xsl:template>
    
    <!-- INDIVIDUAL -->
    
    <xsl:template match="mpx:sachbegriff|mpx:titel|mpx:systematikArt">
        <lido:classification>
            <lido:term xml:lang="de">
                <xsl:value-of select="."/>
            </lido:term>
        </lido:classification>
    </xsl:template>
    
    
    
    
    
    
</xsl:stylesheet>
