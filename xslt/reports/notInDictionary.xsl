<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mpx="http://www.mpx.org/mpx"
    xmlns:dict="http://www.mpx.org/dictionary" exclude-result-prefixes="mpx xs">

    <!-- 
    Andreas wants a list of those sachbegriffe which are not in mpxvok Vokabularmapping
    Compare a dump/MIMO harvest with mpxvok and report those
    	
       saxon.pl latestHarvest.mpx notInDictionary.xsl list.xml
    
    -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <report name="notInDictionary">
            <xsl:for-each-group select="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff"
                group-by=".">
                <xsl:sort data-type="text" lang="de" order="ascending"/>

                <xsl:variable name="thesaurus"
                    select="document('../mpx2lido/dictionary-sachbegriff.xml')"/>

                <xsl:choose>
                    <xsl:when
                        test="$thesaurus/dict:dictionary/dict:concept/dict:synonym[ . eq current-grouping-key()] or $thesaurus/dict:dictionary/dict:concept/dict:pref[ . eq current-grouping-key()]">
                        <!--xsl:message>
                            <xsl:value-of select="current-grouping-key(), 'is a synonym or a pref term!' "/>
                            </xsl:message-->
                    </xsl:when>
                    <xsl:otherwise>
                        <neitherPrefTermNorSynonym type="Sachbegriff">
                            <xsl:value-of select="current-grouping-key()"/>
                        </neitherPrefTermNorSynonym>
                        <xsl:message>
                            <xsl:value-of
                                select="current-grouping-key(), 'is NEITHER a synonym nor a pref term!' "
                            />
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </report>
    </xsl:template>
</xsl:stylesheet>
<!--
                        <xsl:choose>
                        <xsl:when
                        test="$thesaurus/dict:dictionary/dict:concept/dict:pref[ . eq current-grouping-key()]">
                        <xsl:message>
                        <xsl:value-of select="current-grouping-key(), 'is a pref term' "/>
                        </xsl:message>
                        </xsl:when>
                        <xsl:otherwise>
                        <xsl:message>
                        <xsl:value-of select="current-grouping-key(), 'is NOT a pref term' "/>
                        </xsl:message>
                        </xsl:otherwise>
                        </xsl:choose>
-->
