<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

 <xsl:import href="resourceID.xsl"/>

 <!--
  - MIMO wants a resourceSet only for resources which have an URL
  - MIMO generates image URL from resourceID
  - additional URLs for the same resource can be supplied in linkResource;

  Freigabe is currently determined by a mixture of different scripts
  a) basically based on input from mpx-rif or standardbild
  b) 2ndly thru linklint script which checks if resources are available at expected
  ftp location

  mpx:multimediaobjekt/@typ was introduced recently to facilitate type
  recognition
 -->

 <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt">

  <lido:resourceSet>
   <xsl:call-template name="resourceID"/>
   <xsl:call-template name="resourceRepresentation"/>
   <xsl:call-template name="resourceType"/>

   <lido:rightsResource>
    <lido:rightsType>
     <lido:term xml:lang="en">copyright</lido:term>
    </lido:rightsType>
   </lido:rightsResource>

   <xsl:apply-templates select="mpx:multimediaUrhebFotograf"/>
  </lido:resourceSet>
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



 <!--
  NAMED templates
  Paris explicitly wants file name for the URL as resourceID
 -->



 <xsl:template name="resourceRepresentation">
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
</xsl:template>



 <xsl:template name="resourceType">
  <lido:resourceType>
   <lido:term xml:lang="en">
    <xsl:choose>
     <xsl:when test="@typ = 'Audio' ">
      <xsl:text>sound</xsl:text>
     </xsl:when>
     <xsl:when test="@typ = 'Video' ">
      <xsl:text>video</xsl:text>
     </xsl:when>
     <xsl:when test="@typ = 'Bild' ">
      <xsl:text>image</xsl:text>
     </xsl:when>
     <!-- xsl:otherwise>
      <xsl:text>unclear</xsl:text>
      </xsl:otherwise -->
    </xsl:choose>
   </lido:term>
  </lido:resourceType>
 </xsl:template>

</xsl:stylesheet>
