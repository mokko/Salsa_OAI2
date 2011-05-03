<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="repositoryWrap">
        <lido:repositoryWrap>
            <lido:repositorySet lido:type="current">
                <lido:repositoryName>
                    <lido:legalBodyID lido:type="local">SPK</lido:legalBodyID>
                    <lido:legalBodyName>
                        <lido:appellationValue>
                            <!-- Soll hier mpx:credit verwendet werden? -->
                            <xsl:value-of select="child::mpx:verwaltendeInstitution"/>
                        </lido:appellationValue>
                    </lido:legalBodyName>
                    <lido:legalBodyWeblink>http://hv.spk-berlin.de/</lido:legalBodyWeblink>
                </lido:repositoryName>
                <lido:workID lido:type="inventory number">
                    <xsl:value-of select="child::mpx:identNr"/>
                </lido:workID>
                <!-- was tun mit mehrfachen identNr und alten Nr?-->
            </lido:repositorySet>
        </lido:repositoryWrap>
    </xsl:template>
    

</xsl:stylesheet>
