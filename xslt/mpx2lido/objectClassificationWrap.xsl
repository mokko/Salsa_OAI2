<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
 
    <!-- THIRD LEVEL -->
    
    <xsl:template name="objectClassificationWrap">
        
        <lido:objectClassificationWrap>
            <!-- 
                TODO: What to do if objekttyp = Allgemein?
                xsl:if test="child::mpx:objekttyp != 'Allgemein' "
            -->
            <lido:objectWorkTypeWrap>
                <lido:objectWorkType>
                    <lido:term xml:lang="de"><xsl:value-of select="child::mpx:objekttyp"/></lido:term>
                </lido:objectWorkType>
            </lido:objectWorkTypeWrap>
            <!--/xsl:if-->
            
            <xsl:if test="child::mpx:titel or child::mpx:sachbegriff or child::mpx:systematikArt">
                <lido:classificationWrap>
                    <xsl:apply-templates select="child::mpx:sachbegriff"/>
                    <xsl:apply-templates select="child::mpx:titel"/>
                    <xsl:apply-templates select="child::mpx:systematikArt"/>
                </lido:classificationWrap>
            </xsl:if>
        </lido:objectClassificationWrap>
    </xsl:template>
 
</xsl:stylesheet>
