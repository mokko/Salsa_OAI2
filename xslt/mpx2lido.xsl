<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lido="http://www.lido-schema.org"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
  xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

  <xsl:import href="mpx2lido/descriptiveMetadata.xsl"/>
  <xsl:import href="mpx2lido/administrativeMetadata.xsl"/>

  <!--
    mpx2lido : convert mpx to lido as used by MIMO
    http://www.mimo-project.eu
    http://Lido-schema.org
    http://mauricemengel.de

    see mpx2lido/history.txt for global history info
 
    TODO
    <xsl:import href="resourceWrap.xsl"/>
    
    Do not use XSL with 
    
    KNOWN ISSUES
    -The indent function of eclipse's xml editor messes up whitespace in this document.
    -URL in linkResource
    -obj835417 is Trommelschlegel i.e. Teil von Musikinstrument. Wie soll man das erkennen?
    -events not yet implemented    
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
    <xsl:variable name="currentId" select="@objId"/>
    
    <!-- Salsa_OAI doesn't like message   
    
    <xsl:message>xxxxxxxxxxxxxxxxxxxxxblah</xsl:message>
    
    <xsl:message>
      <xsl:value-of select="concat ('objId',$currentId)"/>
    </xsl:message>
    -->
    <lido:lido>
      <lido:lidoRecID lido:type="local">
        <xsl:value-of select="concat ('spk:obj-',@objId)"/>
      </lido:lidoRecID>

      <xsl:call-template name="descriptiveMetadata"/>
      <xsl:call-template name="administrativeMetadata"/>
    </lido:lido>
  </xsl:template>
</xsl:stylesheet>