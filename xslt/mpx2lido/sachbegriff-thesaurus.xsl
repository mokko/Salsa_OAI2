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

    <xsl:template match="mpx:sachbegriff">
        <lido:classification>
            <lido:term xml:lang="de">
                    <xsl:variable name="thesaurus" select="document('dictionary-sachbegriff.xml')"/>
                    <xsl:variable name="this" select="text()"/>

                    <xsl:choose>
                        <!-- either replace with pref or leave original -->
                        <xsl:when test="$thesaurus/dict:dictionary/dict:concept[dict:synonym = $this]">
                            <xsl:value-of select="$thesaurus/dict:dictionary/dict:concept[dict:synonym = $this]/dict:pref"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
             </lido:term>
        </lido:classification>
    </xsl:template>



</xsl:stylesheet>
