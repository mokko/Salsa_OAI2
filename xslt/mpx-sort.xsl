<xsl:stylesheet version="2.0" xmlns="http://www.mpx.org/mpx"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
 <xsl:strip-space elements="*"/>

 <xsl:template match="/">
  <museumPlusExport xsi:schemaLocation="http://www.mpx.org/mpx">

   <xsl:for-each select="/mpx:museumPlusExport/mpx:multimediaobjekt">
    <xsl:sort data-type="number" select="@mulId"/>
    <xsl:call-template name="descendants"/>
   </xsl:for-each>

   <!-- personKörperschaft -->

   <xsl:for-each select="/mpx:museumPlusExport/mpx:personKörperschaft">
    <xsl:sort data-type="number" select="@kueId"/>
    <xsl:call-template name="descendants"/>
   </xsl:for-each>

   <!-- SAMMLUNGSOBJEKT -->

   <xsl:for-each select="/mpx:museumPlusExport/mpx:sammlungsobjekt">
    <xsl:sort data-type="number" select="@objId"/>
     <xsl:call-template name="descendants"/>
   </xsl:for-each>
  </museumPlusExport>
 </xsl:template>

 <xsl:template name="descendants">
  <xsl:element name="{name()}">
   <xsl:for-each select="@*">
    <xsl:attribute name="{name()}">
  <xsl:value-of select="."/>
   </xsl:attribute>
   </xsl:for-each>

   <xsl:for-each select="descendant::*">
    <xsl:sort data-type="text" lang="de" select="name(.)"/>
    <xsl:copy>
     <xsl:copy-of select="@*"/>
     <xsl:value-of select="."/>
    </xsl:copy>
   </xsl:for-each>
  </xsl:element>

 </xsl:template>
</xsl:stylesheet>


