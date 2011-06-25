<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
    
    <xsl:import href="titleWrap.xsl"/>
    <xsl:import href="repositoryWrap.xsl"/>
    <xsl:import href="objectDescriptionWrap.xsl"/>
    <xsl:import href="objectMeasurementsWrap.xsl"/>

    <!-- THIRD LEVEL -->
    
    <xsl:template name="objectIdentificationWrap">
        <lido:objectIdentificationWrap>
            <xsl:call-template name="titleWrap"/>
            <xsl:call-template name="repositoryWrap"/>
            <xsl:call-template name="objectDescriptionWrap"/>
            <xsl:call-template name="objectMeasurementsWrap"/>
        </lido:objectIdentificationWrap>
    </xsl:template>
</xsl:stylesheet>
