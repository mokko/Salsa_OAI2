<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mpx.org/mpx"
 xmlns:mpx="http://www.mpx.org/mpx">

 <xsl:template
  match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:personKörperschaftRef">
  <xsl:copy>
    <xsl:variable name="kueId"
     select="document('perkor.mpx')/mpx:museumPlusExport/mpx:personKörperschaft[ mpx:nennform = current()or mpx:name = current()]/@kueId"/>
   <xsl:if
    test="not (@id) and count ($kueId)= 1">
    <!--
     currently we allow people with the same name to be confused. If should check
     if there is really only one person with that name
    -->
    <xsl:attribute name="id">
     <xsl:value-of select="$kueId"/>
     </xsl:attribute>
    <xsl:message>
     <xsl:text>//mpx:perKör/@id: add id from perkor.mpx:</xsl:text>
     <xsl:value-of select="current()"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$kueId"/>
    </xsl:message>
   </xsl:if>


   <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>

 </xsl:template>


</xsl:stylesheet>