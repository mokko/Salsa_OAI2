<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:import href="objectIdentificationWrap.xsl"/>
    <xsl:import href="objectClassificationWrap.xsl"/>
    <xsl:import href="eventWrap.xsl"/>
    
    <!-- SECOND LEVEL -->

    <xsl:template name="descriptiveMetadata">
        <lido:descriptiveMetadata xml:lang="de">
            <xsl:call-template name="objectClassificationWrap"/>
            <xsl:call-template name="objectIdentificationWrap"/>
            <xsl:call-template name="eventWrap"/>
            <!-- TODO: objectRelationWrap-->
        </lido:descriptiveMetadata>
    </xsl:template>

</xsl:stylesheet>
