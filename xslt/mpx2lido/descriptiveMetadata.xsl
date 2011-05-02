<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <!-- 
        HISTORY
        xml:space="preserve" removed from titlewrap
    -->

    <xsl:import href="objectIdentificationWrap.xsl"/>
    <xsl:import href="objectClassificationWrap.xsl"/>
    
    <!-- SECOND LEVEL -->

    <xsl:template name="descriptiveMetadata">
        <lido:descriptiveMetadata xml:lang="de">
            <xsl:call-template name="objectClassificationWrap"/>
            <xsl:call-template name="objectIdentificationWrap"/>
            <!-- TODO: eventWrap,  objectRelationWrap-->
        </lido:descriptiveMetadata>
    </xsl:template>

</xsl:stylesheet>
