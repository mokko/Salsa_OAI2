<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" xmlns:dict="http://www.mpx.org/dictionary"
    exclude-result-prefixes="mpx dict">
	
    <!-- 
    	WHAT IS THE PURPOSE OF THIS MINI-THESAURUS?
    	1) It adds additional classification terms in lido output for cases
    	   listed in dictionary-sachbegriff.xml (either as pref or synonym).
    	2) In the past, the ideas was NOT to provide (output) only sachbegriffe
    	   that are controlled by Hornbostel-Sachs, but to provide a list that 
    	   MIMO understands. That is MIMO applies a similar transformation, which at 
    	   present I know nothing about and I don't have access to.
    	
    	   If I remember correctly.
    	
    	   This means it would not be bad if we would map everything to a Hornbostel-Sachs
    	   term. Then our Lido Data would be able to stand on its own.
    	
    -->
    
    	

    <xsl:template match="mpx:sachbegriff" mode="classification">
    	<!-- in any case: put original sachbegriff -->
        <lido:classification>
            <lido:term xml:lang="de" lido:encodinganalog="mpx:sachbegriff">
                <xsl:value-of select="."/>
            </lido:term>
        </lido:classification>

        <xsl:variable name="thesaurus" select="document('dictionary-sachbegriff.xml')"/>
        <xsl:variable name="this" select="text()"/>
        
        <!-- if there is a pref term in the MIMO Sachbegriff Mapping, put that too -->
        <xsl:if test="$thesaurus/dict:dictionary/dict:concept[dict:synonym = $this] or 
        	          $thesaurus/dict:dictionary/dict:concept[dict:synonym = $this]/dict:pref">
            <lido:classification>
                <lido:term xml:lang="de" lido:label="SPK's MIMO Keyword Mapping" lido:encodinganalog="mpx:sachbegriff" lido:pref="preferred">
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
