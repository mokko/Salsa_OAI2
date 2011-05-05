<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    it is possible to use XML::LibXSLT's register_function, but that would 
    extend the mapping into perl code and blur important boundaries.
    
    xmlns:func="http://www.mpx.org/mpxfunc"
    xsl:value-of select="func:normalize(.)"
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" xmlns:dict="http://www.mpx.org/dictionary"
    exclude-result-prefixes="mpx dict">

    <xsl:template match="mpx:sachbegriff" mode="classification">
        <lido:classification>
            <lido:term xml:lang="de" encodinganalog="mpx:sachbegriff">
                <xsl:value-of select="."/>
            </lido:term>
        </lido:classification>

        <xsl:variable name="thesaurus" select="document('dictionary-sachbegriff.xml')"/>
        <xsl:variable name="this" select="text()"/>
        <xsl:if test="$thesaurus/dict:dictionary/dict:concept[dict:synonym = $this]">
            <lido:classification>
                <lido:term xml:lang="de" encodinganalog="SPK's MIMO Keyword Mapping">
                            <xsl:value-of select="$thesaurus/dict:dictionary/dict:concept[dict:synonym = $this]/dict:pref"/>
                    </lido:term>
            </lido:classification>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mpx:titel | mpx:systematikArt" mode="classification">
        <lido:classification>
            <xsl:element name="lido:term">
                <xsl:attribute name="xml:lang">de</xsl:attribute>
                <xsl:attribute name="lido:encodinganalog">
                    <xsl:text>mpx:</xsl:text>
                    <xsl:value-of select="name()"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </lido:classification>
        </xsl:template>

</xsl:stylesheet>
