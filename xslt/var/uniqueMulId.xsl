<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:mpx="http://www.mpx.org/mpx">
    <xsl:template match="/">
        <xsl:for-each-group select="/mpx:museumPlusExport/mpx:multimediaobjekt" group-by="@mulId">
            <!--xsl:sort select="@mulId"/-->
            <xsl:if test="count (current-group()) > 1">
                <xsl:message>
                    <xsl:text>mulId </xsl:text>
                    <xsl:value-of select="current-grouping-key()"/>
                    <xsl:text> is not unique!
</xsl:text>
                    <xsl:for-each select="current-group()">
                        <xsl:value-of
                            select="mpx:multimediaPfadangabe,'\',mpx:multimediaDateiname,'.', mpx:multimediaErweiterung"/>
                        <xsl:text>
</xsl:text>
                    </xsl:for-each>
                </xsl:message>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
