<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <!--
        FOURTH LEVEL
        xml:space="preserve"
        there is no guarantee that all titles are German, some are not (ex. shellac). So I better remove xml:lang="de" 
        If neither mpx:titel or mpx:sachbegriff, write nothing & create a non-validating lido so we can find the error easily
    -->
    
    <xsl:template name="titleWrap">
        <lido:titleWrap>
            <xsl:choose>
                <xsl:when test="mpx:titel">
                    <xsl:apply-templates select="mpx:titel" mode="title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="mpx:sachbegriff">
                            <xsl:apply-templates select="mpx:sachbegriff" mode="title"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <lido:titleSet>
                                <lido:appellationValue xml:lang="de">kein
                                Titel</lido:appellationValue>
                            </lido:titleSet>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </lido:titleWrap>
    </xsl:template>

    <!-- INDIVIDUAL -->
    <xsl:template match="mpx:titel | mpx:sachbegriff" mode="title">
        <lido:titleSet>
            <xsl:element name="lido:appellationValue">
                <xsl:attribute name="xml:lang">de</xsl:attribute>
                <xsl:attribute name="lido:label">
                    <xsl:text>mpx:</xsl:text>
                    <xsl:value-of select="name()"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </lido:titleSet>
    </xsl:template>

</xsl:stylesheet>
