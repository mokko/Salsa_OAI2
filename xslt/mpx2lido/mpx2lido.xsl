<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
  xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

  <xsl:import href="descriptiveMetadata.xsl"/>
  <xsl:import href="administrativeMetadata.xsl"/>
  <!--
    <xsl:import href="resourceWrap.xsl"/>
    
    This transformation is supposed to convert mpx to valid lido as used by mimo.
    
    Do not use XSL with eclipse's xml editor because it messes up whitespace.
    

    KNOWN ISSUES
    URL in linkResource
    This file should be better organized, split into several documents that are included or imported! Hence it should
    use <apply-templates> whereever possible.

    HISTORY
    v.006 February 22, 2011 - Lido 1.0 still updating
    v.005 February 17, 2011 - Lido 1.0
    v.004 October 3, 2010
    Check where we are:
    resulting xml validates as LIDO 0.9
    lidoRecID rectified to use colon, use type="local"
    lido:classification/lido:term has mpx:titel, mpx:sachbegriff, mpx:SystematikArt
    lido:classification/lido:term DOES NOT HAVE mpx:identNr


    v.003 September 2, 2010
    converted to XSLT 1.0 for Salsa OAI, resp. XML::LibXSLT

    v.002 May 10,2010
    -correct values in skeleton mapping (lido:titleSet)

    v.001 May 09, 2010
    -create skeleton lido doc so that it validates

    TODO:
    obj835417 is Trommelschlegel i.e. Teil von Musikinstrument. Wie soll man das erkennen?
  -->

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <lido:lidoWrap
      xsi:schemaLocation="http://www.lido-schema.org  http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
      <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt"/>
    </lido:lidoWrap>
  </xsl:template>

  <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
    <xsl:message>xxxxxxxxxxxxxxxxxxxxxblah</xsl:message>
    <xsl:variable name="currentId" select="@objId"/>
    <xsl:message>
      <xsl:value-of select="concat ('objId',$currentId)"/>
    </xsl:message>
    <lido:lido>
      <lido:lidoRecID lido:type="local">
        <xsl:value-of select="concat ('spk:obj-',@objId)"/>
      </lido:lidoRecID>

      <xsl:call-template name="descriptiveMetadata"/>
      <xsl:call-template name="administrativeMetadata"/>
    </lido:lido>
  </xsl:template>
</xsl:stylesheet>
