<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:import href="sachbegriff-thesaurus.xsl"/>
    
    <!-- THIRD LEVEL -->
    
    <xsl:template name="objectClassificationWrap">

        <lido:objectClassificationWrap>
            <!-- 
                TODO: What to do if objekttyp = Allgemein?
                xsl:if test="child::mpx:objekttyp != 'Allgemein' "
            -->
            <lido:objectWorkTypeWrap>
                <lido:objectWorkType>
                    <lido:term xml:lang="de"><xsl:value-of select="mpx:objekttyp"/></lido:term>
                </lido:objectWorkType>
            </lido:objectWorkTypeWrap>
            <!--/xsl:if-->

            <xsl:choose>
                <xsl:when test="mpx:objekttyp = 'Musikinstrument'">
                    <!-- musical instruments may use titel as classification; it may contain einheimische Bezeichnung -->

                    <xsl:if
                        test="child::mpx:titel or child::mpx:sachbegriff or child::mpx:systematikArt">
                        <lido:classificationWrap>
                            <xsl:apply-templates select="mpx:sachbegriff" mode="classification"/>
                            <xsl:apply-templates select="mpx:titel" mode="classification"/>
                            <xsl:apply-templates select="mpx:systematikArt" mode="classification"/>
                        </lido:classificationWrap>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <lido:classificationWrap>
                        <xsl:apply-templates select="mpx:sachbegriff" mode="classification"/>
                        <xsl:apply-templates select="mpx:systematikArt" mode="classification"/>
                    </lido:classificationWrap>
                </xsl:otherwise>
            </xsl:choose>
        </lido:objectClassificationWrap>
    </xsl:template>

</xsl:stylesheet>
