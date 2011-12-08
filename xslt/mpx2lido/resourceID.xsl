<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

 <xsl:template name="resourceID">
  <!-- determine resource path -->
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="lcExt"
   select="translate(mpx:multimediaErweiterung,$uppercase, $smallcase)"/>
  <!-- file conversions done by resmvr.pl this is not good programming, this
   is quick and dirty. If there are more conversions, better move this process
   somewhere else. In mpx-rif, I guess -->
  <xsl:variable name="filename">
   <xsl:value-of select="@mulId"/>
   <xsl:text>.</xsl:text>
   <xsl:choose>
    <xsl:when test="$lcExt = 'tif' or $lcExt = 'tiff'">
     <xsl:text>jpg</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$lcExt"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>


  <xsl:element name="lido:resourceID">
   <xsl:call-template name="preferred"/>
   <xsl:attribute name="lido:type">local</xsl:attribute>
   <xsl:value-of select="$filename"/>
  </xsl:element>
 </xsl:template>


 <xsl:template name="preferred">
  <!--
   NOTE: this does not work anymore with big xml file. It will look for all
   multimediaobjekte regardless of they belong to this sammlungsobjekt
   We have to add
   [mpx:verknüpftesObjekt=$objId]

   MIMO insists that in lido
   -that only images can have preferred status
   -only ever one preferred status per sammlungsobjekt

   in mpx: it is perfectly possible that one object has one video, one image, one
   sound example. Each of them might be characterized with priorität=1
   in mpx.

   $min: the lowest @priorität of any image attached

   slow, but universal:
   ../mpx:multimediaobjekt[mpx:verknüpftesObjekt=$objId]/@priorität[../@typ
   ='Bild']

   a little faster, but works only inside data provider
   ../mpx:multimediaobjekt/@priorität[../@typ ='Bild']

   anything that wants the preferred attribute has to be a image, web-accessible
   and linked
  -->
  <xsl:variable name="objId" select="../mpx:sammlungsobjekt/@objId"/>
  <xsl:if
   test="
     @typ ='Bild' and  
     mpx:verknüpftesObjekt = $objId and
     (@freigabe='Web' or @freigabe='web')
   ">

   <xsl:variable name="candidates"
    select="../mpx:multimediaobjekt[
     @freigabe='Web' or @freigabe='web' and
     mpx:verknüpftesObjekt = $objId and
     @priorität and
     @typ ='Bild' 
   ]"/>

   <!--
    select the group of images which are linked to this object to determine smallest
    priority
   -->
   <xsl:variable name="min">
    <xsl:for-each select="$candidates/@priorität">
     <xsl:sort select="."/>
     <xsl:if test="position() = 1">
      <xsl:value-of select="."/>
     </xsl:if>
    </xsl:for-each>
   </xsl:variable>

   <!-- new: only first IMAGE with $min priority
    FALL APOLLO:
    <xsl:text>&#xa;</xsl:text>
   -->

   <xsl:if test="@priorität = $min">
    <xsl:attribute name="lido:pref">preferred</xsl:attribute>
   </xsl:if>

   <!--
    FALL ATHENA: if no priorität whatsoever, but only one image, put also pref
   -->
   <xsl:if
    test="
   not (@priorität) and
   count(
     ../mpx:multimediaobjekt[
        not (@priorität) and
        mpx:verknüpftesObjekt = $objId and
        @freigabe='Web' or @freigabe='web' and
        @typ ='Bild'
      ]
    ) = 1">
    <xsl:attribute name="lido:pref">preferred</xsl:attribute>
   </xsl:if>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
