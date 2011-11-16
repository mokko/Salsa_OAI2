<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

 <!-- write resourceSet only if URL exists resourceSet - MIMO wants a resourceSet
  only for resources which have an URL - MIMO generates image URL from resourceID
  - additional URLs for the same resource can be supplied in linkResource;
  only publically available URLs Questions -How do I identify mpx:multimediaobjekt
  records which have an image? currently: if local path exists future: mpx2lido
  uses @freigabe="web" and a script determines the freigabe status and writes
  it in mpx. @freigabe="web" write a freigabe script that determines if image
  is available and possibly checks other conditions /mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt
  and @freigabe='web'] -->
 <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt">
  <xsl:variable name="host" select="'http://mmm.de/dir'"/>

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
  <!-- func:doc-available ('$host/$filename') <xsl:if test="1 = 1">
  -->
  <lido:resourceSet>
   <!--
    Paris explicitly and expressly wants file name for the URL as resourceID
   -->
   <xsl:element name="lido:resourceID">
    <xsl:call-template name="preferred"/>
    <xsl:attribute name="lido:type">local</xsl:attribute>
    <xsl:value-of select="$filename"/>
   </xsl:element>
   <!--
    write a resourceRepresentation only if there is a URL (not an internal
    filepath) we have internal path in mpx, but in lido we wanna show only external
    paths so we need to create mume for the dismarc urls
   -->
   <xsl:if test="contains (mpx:multimediaPfadangabe, '://')">
    <lido:resourceRepresentation>
     <lido:linkResource>
      <xsl:value-of
       select="concat(mpx:multimediaPfadangabe,'/',mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)"/>
     </lido:linkResource>
     <!-- internal MuseumPlus paths <xsl:value-of select="concat(mpx:multimediaPfadangabe,'\',mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)"
      /> -->
    </lido:resourceRepresentation>
   </xsl:if>

   <xsl:call-template name="resourceType"/>

   <lido:rightsResource>
    <lido:rightsType>
     <lido:term xml:lang="en">copyright</lido:term>
    </lido:rightsType>
   </lido:rightsResource>
   <xsl:apply-templates select="mpx:multimediaUrhebFotograf"/>
  </lido:resourceSet>
  <!-- </xsl:if> -->
 </xsl:template>

 <xsl:template match="mpx:multimediaUrhebFotograf">
  <!-- I believe the Staatliche Museen zu Berlin want to be named here Ich
   könnte die mulId nehmen und dann Credits aus Sammlungsobjekt nachschlagen. -->

  <lido:rightsResource>
   <lido:creditLine xml:lang="de" lido:encodinganalog="mpx:multimediaUrhebFotograf">
    <xsl:value-of select="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:credits"/>
    <xsl:text> - Foto: </xsl:text>
    <xsl:value-of select="."/>
   </lido:creditLine>
  </lido:rightsResource>
 </xsl:template>


 <!-- NAMED templates -->


 <xsl:template name="resourceType">
  <lido:resourceType>
   <!-- TODO: different media according to which criteria? -->
   <lido:term xml:lang="en">
    <xsl:choose>
     <xsl:when test="@typ = 'Audio' ">
      <xsl:text>sound</xsl:text>
     </xsl:when>
     <xsl:when test="@typ = 'Video' ">
      <xsl:text>movie</xsl:text>
     </xsl:when>
     <xsl:when test="@typ = 'Bild' ">
      <xsl:text>image</xsl:text>
     </xsl:when>
     <!--
      <xsl:otherwise>
      <xsl:message>
      resourceType unclear
      </xsl:message>
      </xsl:otherwise>
     -->
    </xsl:choose>
   </lido:term>
  </lido:resourceType>
 </xsl:template>


 <xsl:template name="preferred">
  <!--
   lookup all priorities for this record and write preferred if this
   one has the lowest priority Not exactly efficient.

   it is perfectly possible that one object has one video, one image, one
   sound example. Each of them might be characterized with priorität=1
   in mpx.

   Theirry/MIMO-Lido wants only one resource (image) with pref=1
  -->
  <xsl:variable name="min">
   <xsl:for-each select="../mpx:multimediaobjekt/@priorität">
    <xsl:sort select="."/>
    <xsl:if test="position() = 1">
     <xsl:value-of select="."/>
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>

  <xsl:if test="@priorität = $min">
   <xsl:variable name="count"
    select="count(../mpx:multimediaobjekt/@priorität[
     . = $min and 
     ../@freigabe='Web' or 
     ../@freigabe='web'])"/>
   <xsl:choose>
    <xsl:when test="$count > 1">
     <xsl:if test="@typ ='Bild'">
      <!--
       it is still possible that there are multiple images of lowest pref, right?
       not really. Currently they would probably overwritten on the filesystem.
       But this is a not a good xslt solution anyways
      -->
     <xsl:call-template name="attrPref"/>
     </xsl:if>
    </xsl:when>

    <!-- if only one resource with lowest pref, disregard type -->
    <xsl:otherwise>
     <xsl:call-template name="attrPref"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="attrPref">
  <xsl:attribute name="lido:pref">preferred</xsl:attribute>
 </xsl:template>

</xsl:stylesheet>
